#!/bin/bash
# Put the list of fonts into a variable
read -r -d '' fonts_list << EOM
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/Marianne-Thin.otf
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/Marianne-Light.otf
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/Marianne-Regular.otf
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/Marianne-Medium.otf
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/Marianne-Bold.otf
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/Marianne-ExtraBold.otf
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/fa-solid-900.eot
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/fa-solid-900.woff2
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/fa-solid-900.woff
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/fa-solid-900.ttf
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/images/fa-solid-900.svg
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/fa-brands-400.eot
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/fa-brands-400.woff2
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/fa-brands-400.woff
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/fonts/fa-brands-400.ttf
https://naturefrance.fr/themes/ofb/ofb_ui/dist/_assets/images/fa-brands-400.svg
EOM

for f in $fonts_list; do
  echo downloading $f
  wget -N --no-check-certificate $f
done
