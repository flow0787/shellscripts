

#!/bin/bash
df -h  | awk '0+$5 >= 80 {print}'
