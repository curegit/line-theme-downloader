# Line Theme Downloader

Small scripts to download theme files from LINE Store

## Requirements

### Bash version

- Bash >= 3.0
- cURL
- `/dev/null` device

### PowerShell version

- PowerShell >= 3.0
- PowerShell >= 6.0 (required only if executing the script directly in UNIX)

## Usage

```
./download.(sh|ps1) PACKAGEID [VERSION]
```

These scripts download theme files in a zip format using HTTP GET.
The zip files are saved in the current directory.

The `PACKAGEID` parameter is always required and specifies which theme to download.
The ID format looks like this: **c6c01199-8d9c-4a7b-860f-8718e40d6bfc**.
You can find them in the URL of theme content pages.

The `VERSION` parameter is optional.
It specifies which version(s) to download.
It must be -1, 0, or a positive integer.
See the following table for synopses of the parameter values.

| VERSION |                behavior                |
|:-------:|----------------------------------------|
|   -1    | Download all the versions.             |
|    0    | Download the latest version. (Default) |
|    n    | Download the specified version.        |

The latest version numbers are being shown inconspicuously in theme content pages.
Versioning starts with v1.00 and increases by 0.01.
To convert them to script parameter format, remove the decimal point and subtract 99.
Notice that the displayed version would be 1 less than the version used in script (v1.00 is mapped to 1).
For example, to download v1.41, you have to pass 42.
For another example, v1.99 is 100, and v2.00 is 101.

## Notes

- The requirement of PowerShell 6.0 or newer to run the script directly in UNIX shells is due to the shebang problem.
- The theme files are located in public web directories, so anyone can get them easily and legally (for private use only).

## Related

[Line Sticker Downloader](https://github.com/curegit/line-sticker-downloader)

## License

[WTFPL](LICENSE)
