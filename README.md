# Firefighting Hose Script

This script provides a realistic firefighting experience in Fivem with QBCore Framework, allowing players with specific jobs to equip and use a water hose. The hose can only be used near designated vehicles.

## Features

- Equip/unequip a water hose using a command.
- Only players with specific jobs can use the hose.
- Hose can only be used when near certain vehicles.
- Realistic water particle effects for the hose.
- Configurable jobs, vehicles, and command.

## Requirements

- QBCore Framework

## Installation

1. Clone or download this repository.
2. Place the folder in your `resources` directory.
3. Add the following line to your `server.cfg`:

```plaintext
ensure firefighting-hose
```

## Configuration

The script can be configured using the `config.lua` file.

### Configurable Options

- **AllowedJobs**: List of job names that are allowed to use the hose.
- **AllowedVehicles**: List of vehicle models that the player must be near to use the hose.
- **MaxDistance**: Maximum distance from the vehicle to be able to use the hose.
- **HoseCommand**: Command used to equip/unequip the hose.

### Example `config.lua`

```lua
Config = {}

-- List of allowed jobs
Config.AllowedJobs = {
    'ambulance',
    'firefighter'
}

-- List of allowed vehicles
Config.AllowedVehicles = {
    'firetruk',
    'firetruck2'
}

-- Maximum distance to vehicle
Config.MaxDistance = 50

-- Command to equip/unequip hose
Config.HoseCommand = 'hose'
```

## Usage

1. Make sure you have the appropriate job.
2. Ensure you are near one of the allowed vehicles.
3. Use the command defined in the config (default is `/hose`) to equip or unequip the hose.

## Commands

- `/hose`: Equip/unequip your hose (default command, can be changed in `config.lua`).

## Notes

- The script checks your job and vehicle proximity each time you try to use the hose.
- If you move too far from the allowed vehicle, the hose will be automatically removed.

## Disclaimer
- This script is not mine and im not claiming this to be mine, im just editing the script to be able to check for job, vehicle, and range of the vehicle
  and also make sure it's working fine with qbcore, don't expect perfection from this script since this is my first script and also helped by chatgpt

## Authors

- [London Studios & Adam Fenton (Original Script)](https://github.com/LondonStudios/HoseLS)
- Converted to Lua by [Dr0msis and Pingouin#8843](https://github.com/pingouinn/HoseLS/tree/Updated)

## License

This project is licensed under the MIT License.

