# Handlebars

The nodejs version of handlebars is used for templating until a C# or rust
commandline utility is built to replace the code for powershell and javascript.

## helpers

- `get-env` will grab an environment variable
- `get-env-bool` will grab an environment variable and will evaluate it to true or false.
- `new-password` will generate a password with a given length and special characters. The
    length defeaults to 16 if the password does not already exist for a given key.
- `is-windows` returns true if the os is windows.
- `is-darwin` returns true if the os is mac os.
- `cat` will read on or more files and return all of the results. useful for pulling in config files
  into docker compose.
- `concat-target` prepend the current env target to a string e.g. dev, prod, staging, etc.
- `bcrypt-password` will take an existing password and apply the bcrypt hash.