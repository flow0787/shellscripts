#!/bin/bash
# AUTHOR: FLORIN BADEA for Support Eng application @ GitLab
# DESCRIPTION: Script which takes a folder or path as argument
# and filters all files inside to 3 folders by size: small, medium, large
# USAGE: ./filesorter.sh $FOLDER_NAME
#        ./filesorter.sh $FOLDER_PATH

# save the folder name or path as folder_to_sort (script's first argument)
folder_to_sort=$1


# if the folder_to_sort exists then continue
if [ -d "$folder_to_sort" ]; then

  # if the small directory exists
  if [ -d "small" ]; then
    # find all files under 500k and copy them inside the small folder
    find $folder_to_sort -type f -size +0k -size -500k -exec cp -rf {} small \;
  # if not, create it then copy as per above
  else
    mkdir small
    find $folder_to_sort -type f -size +0k -size -500k -exec cp -rf {} small \;
  fi
  if [ -d "medium" ]; then
    find $folder_to_sort -type f -size +500k -size -1000k -exec cp -rf {} medium \;
  else
    mkdir medium
    find $folder_to_sort -type f -size +500k -size -1000k -exec cp -rf {} medium \;
  fi
  if [ -d "large" ]; then
    find $folder_to_sort -type f -size +1M -exec cp -rf {} large \;
  else
    mkdir large
    find $folder_to_sort -type f -size +1M -exec cp -rf {} large \;
  fi

# if the folder_to_sort does not exist, echo this out
else
  echo "Folder/Path $folder_to_sort does not exist"
fi
#### END SCRIPT ####
