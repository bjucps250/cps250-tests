# README

To run tests locally:

```
cd submission-folder
run lab1
```

To run tests interactively:

```
cd submission-folder
runi
# rt lab1
```

# Configuring Assignments

Create config.sh in an assignment folder to specify assignment configuration.

Options include:
* INSTALL_PACKAGES - specify packages to install

  ```
  INSTALL_PACKAGES="valgrind libbsd-dev"
  ```

* NO_PACKAGE_CACHE - set to 1 to prevent GitHub from caching INSTALL_PACKAGES (during initial testing)

* TIMEOUT - overall timeout in seconds for the test (default 30)
