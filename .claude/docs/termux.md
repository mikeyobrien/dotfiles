## Termux Environment

### System Environment

- You are running in Termux on Android, not a traditional Linux environment
- Working directory: `/data/data/com.termux/files/home`
- Shell: Fish shell is the default shell in this environment
- Package manager: Use `pkg` (wrapper around apt) for system packages
- Python package manager: Use `uv` for Python dependencies

### Termux-Specific Commands

```bash
# Package management
pkg update                    # Update package lists
pkg upgrade                   # Upgrade installed packages
pkg install <package>         # Install a package
pkg search <pattern>          # Search for packages
pkg show <package>            # Show package details

# Storage access
termux-setup-storage          # Grant access to shared storage

# Services
sv-enable <service>           # Enable a service (requires termux-services)
sv-disable <service>          # Disable a service
sv status <service>           # Check service status

# API access
termux-battery-status         # Get battery information
termux-notification           # Show notifications
termux-vibrate                # Vibrate the device
```

### Common Issues and Solutions

#### Permission Denied Errors
- Termux has a non-standard filesystem layout
- Cannot access system directories like `/etc`, `/usr`, etc.
- All user files should be in `/data/data/com.termux/files/home`
- Use `termux-setup-storage` to access external storage

#### Python/pip Issues
- Always use `uv` instead of pip/poetry
- System Python is managed by Termux packages
- Virtual environments are recommended for isolation

#### Service Management
- Traditional systemd/init.d don't work in Termux
- Use `termux-services` package for daemon management
- Services run under runit supervision

#### Build/Compilation Issues
- Some packages require `build-essential` equivalent: `pkg install build-essential`
- For Python packages with C extensions: `pkg install python-dev`
- Limited compiler toolchain compared to desktop Linux

### File System Layout

```
/data/data/com.termux/files/
├── home/              # User home directory ($HOME)
├── usr/               # Termux prefix (like /usr on Linux)
│   ├── bin/           # Executables
│   ├── lib/           # Libraries
│   ├── share/         # Shared data
│   └── etc/           # Configuration files
└── tmp/               # Temporary files
```

### Environment Variables

- `$PREFIX` = `/data/data/com.termux/files/usr`
- `$HOME` = `/data/data/com.termux/files/home`
- `$TMPDIR` = `/data/data/com.termux/files/usr/tmp`

### Networking Considerations

- Some ports below 1024 may not be bindable without root
- Use higher ports (8000+) for development servers
- VPN and proxy settings may affect connectivity

### Fish Shell Specifics

- Config file: `~/.config/fish/config.fish`
- Aliases are defined directly (not in `.bashrc`)
- Use `source ~/.config/fish/config.fish` to reload config
- Functions are preferred over aliases for complex commands

### Claude Code Alias

An alias `c` has been configured for `claude --dangerously-skip-permissions` to bypass permission prompts in this trusted environment.