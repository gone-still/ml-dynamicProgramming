# ml-dynamicPrograming
A custom Dynamic Programming (DP) Matlab script that measure distance (or similarity) between two strings.
The script tries to map out the number of operations (Matches, Replacements, Insertions and Deletions) into a numerical score value.

Some test strings and their scores:
> String A = “tree” & String B = “three” Score: 0.85

> String A = “muppet” & String B = “puppet” Score: 0.875

> String A = “gone” & String B = “still” Score: 0.25

> String A = “110110” & String B = “010111” Score: 0.72917
