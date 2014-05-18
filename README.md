OCLC Import 
===========

Search OCLC records and choose which ones to import into ArchivesSpace as Accession records.

# Getting Started

Download the latest release from the Releases tab in Github:

  https://github.com/lcdhoffman/aspace_oclc/releases

Unzip the release and move it to:

    /path/to/archivesspace/plugins

Unzip it:

    $ cd /path/to/archivesspace/plugins
    $ unzip oclc.zip -d oclc

Enable the plugin by editing the file in `config/config.rb`:

    AppConfig[:plugins] = ['some_plugin', 'oclc']

(Make sure you uncomment this line (i.e., remove the leading '#' if present))

See also:

  https://github.com/archivesspace/archivesspace/blob/master/plugins/README.md

Note that the plugin directory must be 'oclc' or the menu item will not appear in the staff UI.

Note that this plugin will not work with a version of ArchivesSpace that is missing this commit, which adds the accession importer:

  https://github.com/hudmol/archivesspace/commit/25eab1e77d4c0493e3a165251605b962b4a8c574

# How it works

Users with appropriate permissions will be able to use a menu item
in the Plugins section of the toolbar to import OCLC records.

Start by entering a search term and viewing the results. Select items to import by clicking "Select". Start the import job by clicking "Import"

