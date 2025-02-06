# Thesis
### Code tied to thesis
About this repo
- main-scripts contains the primary scripts used for data and figure generation.
- supplemental-scripts are smaller scripts used to complete a specific function, or isolated functions that can be used to perform a specific task like returning today's date in YYYY-MM-DD format.
- The .java scripts are actually .ijm (IJMacro), ImageJ's built-in scripting language. They are only .java here to allow for GitHub syntax highlighting.

Many of the scripts expect a directory structure in this format:
```
root
├── code
├── data
└── results
```

Where:
- code contains the executed scripts
- data contains the raw tiff files
- results contains subdirectories labeled by extension ( i.e. ".tif/", ".csv/", etc.)