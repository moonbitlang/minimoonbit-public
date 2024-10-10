import { readFileSync } from 'fs'
import process from 'process'

let memory = new WebAssembly.Memory({ initial: 10, maximum: 1000 })

async function read(stream) {
    const chunks = [];
    for await (const chunk of stream) chunks.push(chunk);
    return Buffer.concat(chunks).toString('utf8');
}
let input = await read(process.stdin)

let ptr = 0

let offset = 0

let whitespace_regex = /^\s+/
let int_regex = /^-?\d+/

let importObject = {
    minimbt_read_int: () => {
        // skip whitespace
        let ws_result = whitespace_regex.exec(input.slice(ptr))
        if (ws_result !== null) {
            ptr += ws_result[0].length
        }
        // Parse int
        let result = int_regex.exec(input.slice(ptr))
        if (result === null) {
            throw new Error('Invalid input')
        }
        ptr += result[0].length
        return parseInt(result[0])
    },
    minimbt_read_char: () => {
        return input[ptr++].charCodeAt(0)
    },
    minimbt_print_int: (value) => process.stdout.write(`${value}`),
    minimbt_print_char: (value) => process.stdout.write(String.fromCharCode(value)),
    minimbt_print_endline: () => process.stdout.write('\n'),
    minimbt_print_newline: () => process.stdout.write('\n'),
    minimbt_malloc: (size) => {
        if (memory.buffer.byteLength < offset + size) {
            memory.grow(1)
        }
        let ptr = offset
        offset += size
        return ptr;
    },
    minimbt_create_array: (size, initial) => {
        if (memory.buffer.byteLength < offset + size * 4) {
            memory.grow(1)
        }
        let view = new Int32Array(memory, offset, size);
        view.fill(initial)
        let ptr = offset
        offset += size * 4
        return ptr;
    },
    minimbt_create_float_array: (size, initial) => {
        if (memory.buffer.byteLength < offset + size * 8) {
            memory.grow(1)
        }
        let view = new Float64Array(memory, offset, size);
        view.fill(initial)
        let ptr = offset
        offset += size * 8
        return ptr;
    },
    minimbt_create_ptr_array: (size, initial) => {
        if (memory.buffer.byteLength < offset + size) {
            memory.grow(1)
        }
        let view = new Uint32Array(memory, offset, size);
        view.fill(initial >>> 0)
        let ptr = offset
        offset += size
        return ptr;
    },
    minimbt_int_of_float: (f) => Math.trunc(f),
    minimbt_float_of_int: (i) => i,
    minimbt_truncate: (f) => Math.trunc(f),
    minimbt_floor: (f) => Math.floor(f),
    minimbt_abs_float: (f) => Math.abs(f),
    minimbt_sqrt: (f) => Math.sqrt(f),
    minimbt_sin: (f) => Math.sin(f),
    minimbt_cos: (f) => Math.cos(f),
    minimbt_atan: (f) => Math.atan(f),
    memory
}

let wasm_name = process.argv[2]
let wasm_code = readFileSync(wasm_name)
// User code in start section, so no need to run the main function
let _instance = await WebAssembly.instantiate(wasm_code, { moonbit: importObject })
