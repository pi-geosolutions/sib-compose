#!/bin/bash

# move SIB thesauri from external to local path
# GN flat form is configured for local thesauri, not external
# But when importing a thesaurus from the UI, you don't have the choice, it's put in externals

DATADIR_PATH=volumes/geonetwork_data

for th in opendata datatype politiquepublique thematiques dpsir ebv; do
  #echo $th.rdf
  external_theme_path=$DATADIR_PATH/config/codelist/external/thesauri/theme
  local_theme_path=$DATADIR_PATH/config/codelist/local/thesauri/theme
  if [[ -f "$external_theme_path/$th.rdf" ]]; then
      sudo mv $external_theme_path/$th.rdf $local_theme_path/$th.rdf
  else
    echo "$external_theme_path/$th.rdf not found"
  fi
done
