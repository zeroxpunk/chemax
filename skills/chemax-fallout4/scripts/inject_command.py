"""
chemax - Fallout 4 console command injector
Calls the game's internal script execution function via pymem.
No keystrokes, no clipboard, no bat files.

Usage: python inject_command.py "player.additem 0000000f 10000"
"""

import sys
import struct
import ctypes
import ctypes.wintypes
import pymem
import pymem.process
import pymem.pattern

TESSSCRIPT_SIZE = 0x178
COMPILER_SYSWINDOW = 1


def resolve_rip_call(pm, addr):
    """Resolve a RIP-relative CALL (E8 xx xx xx xx) to absolute address."""
    offset = struct.unpack('<i', pm.read_bytes(addr + 1, 4))[0]
    return addr + 5 + offset


def find_functions(pm, module):
    """AOB scan to find all TESScript functions."""
    pattern = rb'\x41\xB8\x01\x00\x00\x00\x48\x89\x44\x24\x78'
    match = pymem.pattern.pattern_scan_module(pm.process_handle, module, pattern)
    if not match:
        raise RuntimeError("AOB pattern not found")

    wrapper = match - 0x4E
    print(f"  wrapper: {wrapper:#x}")

    funcs = {
        'Constructor':     resolve_rip_call(pm, wrapper + 0x18),
        'MarkAsTemporary': resolve_rip_call(pm, wrapper + 0x22),
        'SetText':         resolve_rip_call(pm, wrapper + 0x2F),
        'CompileAndRun':   resolve_rip_call(pm, wrapper + 0x59),
        'Destructor':      resolve_rip_call(pm, wrapper + 0x63),
    }

    for name, addr in funcs.items():
        print(f"  {name}: {addr:#x}")
    return funcs


def find_global_script_state(pm, module):
    """Find the global script state pointer via AOB."""
    pattern = rb'\x75\xF7\x85\xC0\x74\x32'
    match = pymem.pattern.pattern_scan_module(pm.process_handle, module, pattern)
    if not match:
        raise RuntimeError("GlobalScriptState AOB not found")

    memptr = match + 0x6
    offset = struct.unpack('<i', pm.read_bytes(memptr + 3, 4))[0]
    rip = memptr + 3 + 4
    addr = rip + offset
    print(f"  GlobalScriptState: {addr:#x}")
    return addr


def mov_rax_imm64(val):
    """Encode: movabs rax, <64-bit immediate>"""
    return b'\x48\xB8' + struct.pack('<Q', val)

def mov_rcx_imm64(val):
    """Encode: movabs rcx, <64-bit immediate>"""
    return b'\x48\xB9' + struct.pack('<Q', val)

def mov_rdx_imm64(val):
    """Encode: movabs rdx, <64-bit immediate>"""
    return b'\x48\xBA' + struct.pack('<Q', val)

def call_rax():
    """Encode: call rax"""
    return b'\xFF\xD0'

def mov_rdx_rax_deref():
    """Encode: mov rdx, [rax]"""
    return b'\x48\x8B\x10'

def mov_r8d_imm32(val):
    """Encode: mov r8d, <32-bit immediate>"""
    return b'\x41\xB8' + struct.pack('<I', val)

def xor_r9_r9():
    """Encode: xor r9, r9"""
    return b'\x4D\x31\xC9'


def build_shellcode(funcs, global_state_ptr, script_obj_addr, text_addr):
    """Build x64 shellcode to execute a console command."""
    code = bytearray()

    # Prologue
    code += b'\x55'                          # push rbp
    code += b'\x48\x89\xE5'                 # mov rbp, rsp
    code += b'\x48\x83\xEC\x60'             # sub rsp, 0x60

    # TESScript_Constructor(rcx = scriptObject)
    code += mov_rcx_imm64(script_obj_addr)
    code += mov_rax_imm64(funcs['Constructor'])
    code += call_rax()

    # TESScript_MarkAsTemporary(rcx = scriptObject)
    code += mov_rcx_imm64(script_obj_addr)
    code += mov_rax_imm64(funcs['MarkAsTemporary'])
    code += call_rax()

    # TESScript_SetText(rcx = scriptObject, rdx = text)
    code += mov_rcx_imm64(script_obj_addr)
    code += mov_rdx_imm64(text_addr)
    code += mov_rax_imm64(funcs['SetText'])
    code += call_rax()

    # Load GlobalScriptState: rdx = *global_state_ptr
    code += mov_rax_imm64(global_state_ptr)
    code += mov_rdx_rax_deref()

    # TESScript_CompileAndRun(rcx = scriptObject, rdx = globalState, r8d = 1, r9 = 0)
    code += mov_rcx_imm64(script_obj_addr)
    # rdx already set above
    code += mov_r8d_imm32(COMPILER_SYSWINDOW)
    code += xor_r9_r9()
    code += mov_rax_imm64(funcs['CompileAndRun'])
    code += call_rax()

    # TESScript_Destructor(rcx = scriptObject)
    code += mov_rcx_imm64(script_obj_addr)
    code += mov_rax_imm64(funcs['Destructor'])
    code += call_rax()

    # Epilogue
    code += b'\x48\x83\xC4\x60'             # add rsp, 0x60
    code += b'\x5D'                          # pop rbp
    code += b'\xC3'                          # ret

    return bytes(code)


def execute_command(command: str):
    """Execute a console command in Fallout 4."""
    print(f"[chemax] executing: {command}")

    pm = pymem.Pymem("Fallout4.exe")
    module = pymem.process.module_from_name(pm.process_handle, "Fallout4.exe")

    print("[chemax] scanning...")
    funcs = find_functions(pm, module)
    global_state_ptr = find_global_script_state(pm, module)

    # Allocate memory in the game process
    cmd_bytes = command.encode('ascii') + b'\x00'
    text_addr = pm.allocate(len(cmd_bytes) + 16)
    pm.write_bytes(text_addr, cmd_bytes, len(cmd_bytes))
    print(f"  text at {text_addr:#x}")

    script_obj_addr = pm.allocate(TESSSCRIPT_SIZE + 64)
    pm.write_bytes(script_obj_addr, b'\x00' * TESSSCRIPT_SIZE, TESSSCRIPT_SIZE)
    print(f"  script obj at {script_obj_addr:#x}")

    shellcode = build_shellcode(funcs, global_state_ptr, script_obj_addr, text_addr)
    shellcode_addr = pm.allocate(len(shellcode) + 64)
    pm.write_bytes(shellcode_addr, shellcode, len(shellcode))
    print(f"  shellcode at {shellcode_addr:#x} ({len(shellcode)} bytes)")

    print("[chemax] injecting...")
    thread_h = pm.start_thread(shellcode_addr)

    ctypes.windll.kernel32.WaitForSingleObject(
        ctypes.wintypes.HANDLE(thread_h), 5000
    )

    # Cleanup
    MEM_RELEASE = 0x8000
    k32 = ctypes.windll.kernel32
    k32.VirtualFreeEx.argtypes = [
        ctypes.wintypes.HANDLE, ctypes.c_ulonglong,
        ctypes.c_size_t, ctypes.wintypes.DWORD
    ]
    k32.VirtualFreeEx(pm.process_handle, text_addr, 0, MEM_RELEASE)
    k32.VirtualFreeEx(pm.process_handle, script_obj_addr, 0, MEM_RELEASE)
    k32.VirtualFreeEx(pm.process_handle, shellcode_addr, 0, MEM_RELEASE)

    print("[chemax] done!")


if __name__ == "__main__":
    if len(sys.argv) < 2:
        print('Usage: python inject_command.py "<console command>"')
        sys.exit(1)
    execute_command(sys.argv[1])
