A simple controller for SRAM IS61WV12816BLL-10BLI.

## Features
* A0-A18 Address
* D0-D15 Data

## Usage
* `clk` no more than 100MHz
* `rw` to control the read/write
    * When `rw == 1'b1`, write
    * When `rw == 1'b0`, read
* When the operations complete, the `read_finish` or `write_finish` will generate a high voltage pulse and last a clock period.

## License
[BSD3 License](./LICENSE)
