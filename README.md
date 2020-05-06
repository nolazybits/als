# Setup

## Environment Variables:
* HUGO_THEME
* HUGO_WATCH (set to any value to enable watching)
* HUGO_DESTINATION (Path where hugo will render the site. By default /output)
* HUGO_REFRESH_TIME (in seconds, only applies if not watching, if not set, the container will build once and exit)
* HUGO_BASEURL
* HUGO_PORT

# Executing
Just run the following command  
`./start.sh`

This will create a new hugo site in the source folder.
From there, do as usual, install a theme and rerun `./start.sh`, now a watcher will be watching for changes...

# FAQ

**OCI runtime exec failed: exec failed: container_linux.go:344: starting container process caused "chdir to cwd (\"/hugo/src\") set in config.json failed: no such file or directory": unknown**  
`./start.sh --build` will force rebuilding your container and will recreate the src folder you have deleted.