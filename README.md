# Volumio Custom Overlays

Device Tree overlays for Volumio on Raspberry Pi systems using I2S DACs based on the ES9018K2M chipset. These overlays are designed for Linux kernel 6.6+ and address audio timing issues caused by missing or mismatched master clock (MCLK) configurations.

The repository provides overlays for two common types of ES9018K2M boards:

- Boards that **require MCLK from the host** (typically via GPIO4)
- Boards that include an **onboard oscillator** and are fully self-clocked

Overlays are compatible with Raspberry Pi 4 and newer, using Volumio 3.x builds.


## Overlay Files

- `es9018k2m-type-a`: Enables fixed MCLK output via GPIO4. Use this with DAC boards that do **not** have onboard oscillators.
- `es9018k2m-type-b`: For DAC boards with onboard oscillators. MCLK is not supplied by the Pi.
- `es9018k2m-debug`: Variant of `type-a` with distinct ALSA name and support for debug instrumentation.


## Usage

1. Copy the desired `.dtbo` files from the `dtbo/` directory to your Volumio system:
   ```bash
   sudo cp dtbo/*.dtbo /boot/overlays/
   ```

2. Edit `/boot/userconfig.txt` and add the desired overlay configuration, for example:
   ```ini
   dtoverlay=es9018k2m-type-a
   ```

3. Add any overlay parameters as needed (see below).

4. Reboot the system.


## Overlay Parameters

### `es9018k2m-type-a` Parameters

| Parameter         | Description                                              | Default       |
|------------------|----------------------------------------------------------|---------------|
| `mclk-fs`         | MCLK = SampleRate × N (use 256 or 384)                  | `256`         |
| `alsaname`        | ALSA card identifier                                    | `ES9018K2M`   |
| `mclk-gpio`       | GPIO pin to output MCLK (must be valid alternate func)  | `4` (GPIO4)   |
| `clock-frequency` | Fixed MCLK frequency in Hz                              | `11289600`    |

#### MCLK Frequency Calculation

MCLK is derived from the sample rate and a multiplier, typically 256 or 384:

```
MCLK = SampleRate × Multiplier
```

Common values:

| Sample Rate | ×256 (Hz) | ×384 (Hz) |
|-------------|-----------|-----------|
| 44.1 kHz    | 11289600  | 16934400  |
| 48 kHz      | 12288000  | 18432000  |
| 96 kHz      | 24576000  | 36864000  |

Choose a value that matches your DAC's expected base rate family. For mixed format playback, 11.2896 MHz (44.1kHz family) or 12.288 MHz (48kHz family) are common.

**Example:**
```ini
dtoverlay=es9018k2m-type-a,alsaname="ES9018-MCLK",mclk-fs=256,clock-frequency=11289600
```


### `es9018k2m-type-b` Parameters

| Parameter  | Description                     | Default              |
|------------|---------------------------------|----------------------|
| `alsaname` | ALSA card identifier            | `ES9018K2M-Self`     |

**Example:**
```ini
dtoverlay=es9018k2m-type-b,alsaname="ES9018-OSC"
```

Use this with DAC boards that have their own onboard clock and do not require MCLK from the host.


## Building

To compile overlays from source:

```bash
./build/build.sh
```

This script scans the `overlays/` directory and compiles all `.dts` files to `.dtbo` format into the `dtbo/` output directory. It automatically checks for `dtc` (Device Tree Compiler).


## Requirements

- Linux host with `device-tree-compiler` installed
- Kernel 6.1+ recommended, 6.6+ preferred for full compatibility with newer overlay syntax

Install `dtc` on Debian/Ubuntu:

```bash
sudo apt install device-tree-compiler
```


## Notes

- MCLK generation requires a DAC board that can accept an external master clock.
- Some ES9018K2M boards labeled “I2S DAC” do not function without MCLK — these require the `type-a` overlay.
- The overlays assume stereo, 2-channel configuration with 24-bit or 32-bit depth.
- For custom frequencies or pinouts, edit the `.dts` source files before compiling.
