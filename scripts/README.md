# Build File Generation Scripts

This directory contains scripts and templates for automatically generating BUILD files for protobuf-generated code.

## Structure

```
scripts/
├── README.md                      # This file
├── create_gen_build_files.sh      # Main orchestrator script
├── create_cpp_build_files.sh      # C++ BUILD file generator
├── create_go_build_files.sh       # Go BUILD file and go.mod generator
├── create_python_build_files.sh   # Python BUILD file and package generator
└── templates/
    ├── cpp_BUILD.bazel            # C++ BUILD file template
    ├── go_BUILD.bazel             # Go BUILD file template
    ├── go_mod                     # Go go.mod file template
    └── python_BUILD.bazel         # Python BUILD file template
```

## Usage

### Main Script
Run the main orchestrator script after `buf generate`:
```bash
./scripts/create_gen_build_files.sh
```

This script automatically calls all language-specific scripts.

### Individual Language Scripts
You can also run individual language scripts:
```bash
./scripts/create_cpp_build_files.sh
./scripts/create_go_build_files.sh
./scripts/create_python_build_files.sh
```

### Automatic Execution
The main script is automatically called by the Makefile after `buf generate`:
```bash
make generate  # Runs buf generate + creates BUILD files + sets up Python IDE
```

### Python IDE Support
The `create_python_build_files.sh` script automatically creates proper Python package structure for IDE support:
- Creates `__init__.py` files in each `gen/python/*/` directory
- Makes generated protobuf files importable by IDEs
- VS Code is automatically configured via `.vscode/settings.json` to use `gen/python` as an extra path

This enables IDE features like:
- Import autocomplete for generated protobuf files
- Type hints and error checking
- Go-to-definition for protobuf classes

## Templates

### Template Variables
Templates use `{{VARIABLE_NAME}}` syntax for substitution:

- `{{SERVICE_NAME}}`: The name of the service (e.g., "product", "order", "user")
- `{{IMPORT_PATH}}`: The Go import path (e.g., "github.com/8bit-euclid/grpc-sandbox/gen/go/product")

### Customizing Templates
To modify the generated BUILD files, edit the template files in `scripts/templates/`.

### Adding New Languages
To add support for a new language:
1. Create a template file in `scripts/templates/`
2. Create a language-specific script in `scripts/`
3. Add the script call to `scripts/create_gen_build_files.sh`

## Generated Files

The scripts generate the following files in the `gen/` directory:

### C++
- `gen/c++/*/BUILD` - Bazel BUILD file for C++ protobuf libraries

### Go
- `gen/go/*/BUILD` - Bazel BUILD file for Go protobuf libraries
- `gen/go/*/go.mod` - Go module file for the generated code

### Python
- `gen/python/*/BUILD` - Bazel BUILD file for Python protobuf libraries
- `gen/python/*/__init__.py` - Python package files for IDE support

## Notes

- All generated files are automatically recreated when `buf generate` runs
- The `gen/` directory is cleared before regeneration, so any manual changes will be lost
- Templates are designed to work with the current protobuf generation setup
- Scripts include error checking and will skip missing directories gracefully
