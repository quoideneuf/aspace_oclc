OCLC Import 
===========

Search OCLC records and choose which ones to import into ArchivesSpace as Accession records.

# Getting Started

Download the latest release from the Releases tab in Github:

  https://github.com/lcdhoffman/aspace_oclc/releases

Unzip it to the plugins directory:

    $ cd /path/to/archivesspace/plugins
    $ unzip /path/to/your/downloaded/oclc.zip -d oclc

Enable the plugin by editing the file in `config/config.rb`:

    AppConfig[:plugins] = ['some_plugin', 'oclc']

(Make sure you uncomment this line (i.e., remove the leading '#' if present))

See also:

  https://github.com/archivesspace/archivesspace/blob/master/plugins/README.md

You will need a key, secret, and principal_id for the OCLC Metadata API: 
 
    AppConfig[:oclc_metadata_key] = { Your Metadata API Key }
    AppConfig[:oclc_metadata_secret] = { Your Metadata API Key }
    AppConfig[:oclc_principal_id] = { Your OCLC Principal ID }

Contact OCLC to acquire these. You can read about the service here:

  http://www.oclc.org/developer/develop/web-services/worldcat-metadata-api.en.html

Note that this plugin will not work with a version of ArchivesSpace that is missing this commit, which adds the accession importer:

  https://github.com/hudmol/archivesspace/commit/25eab1e77d4c0493e3a165251605b962b4a8c574

# How it works

Users with appropriate permissions will be able to use a menu item
in the Plugins section of the toolbar to import OCLC records.

Start by entering a list of OCLC numbers and previewing the results. Start the import job by clicking "Import".

