from ipykernel.kernelbase import Kernel
from lupa import LuaRuntime
import sys

class QKernel(Kernel):
    implementation = 'Q'
    implementation_version = '1.0'
    language = 'no-op'
    language_version = '0.1'
    language_info = {
        'name': 'Any text',
        'mimetype': 'text/plain',
        'file_extension': '.txt',
    }
    banner = "Q kernel - enjoy analytics"
    
    lua = LuaRuntime(unpack_returned_tuples=True)
    lua.execute("Q = require 'Q'")

    def do_execute(self, code, silent, store_history=True, user_expressions=None,
                   allow_stdin=False):
        if not silent:
            try:
                result = QKernel.lua.execute(code)
            except Exception as exc:
                result = str(exc)
            #with open("/tmp/output.txt", "a") as f:
            #    f.write("%s\n" % str(result))
            if not result:
                result = ''
            stream_content = {'name': 'stdout', 'text': str(result)}
            self.send_response(self.iopub_socket, 'stream', stream_content)

        return {'status': 'ok',
                # The base class increments the execution count
                'execution_count': self.execution_count,
                'payload': [],
                'user_expressions': {},
               }
