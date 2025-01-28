#!/usr/bin/env python3
import os
import sys

# Desktop file data
# {
#     "name": {
#         "path": path,
#         "exec": exec_line,
#         "term": is_term
#     }
# }

directory = os.path.expanduser("~/.local/share/applications/")
filenames = list(map(lambda fname: os.path.join(directory, fname), \
                     os.listdir(directory)))
directory = "/usr/share/applications/"
filenames.extend(list(map(lambda fname: os.path.join(directory, fname), \
                          os.listdir(directory))))

names = []
entries = {}
for filename in filenames:
    entry = {"exec": "", "path": filename, "term": False}
    name = ""
    is_hidden = False
    with open(filename, "r") as file:
        for line in file.readlines():
            if line.startswith("Name") and not name:
                name_key = line.split("=", 1)[0]
                if "[" in name_key:
                    continue
                tmp_name = line.split("=", 1)[1].strip()
                if tmp_name in names:
                    break
                else:
                    name = tmp_name
            elif line.startswith("Exec") and not entry["exec"]:
                entry["exec"] = line.split("=", 1)[1].strip()
            elif line.startswith("Terminal"):
                if line.split("=", 1)[1].strip().lower() == "true":
                    entry["term"] = True
            elif line.startswith("NoDisplay") or line.startswith("Hidden"):
                if line.split("=", 1)[1].strip().lower() == "true":
                    is_hidden = True
                    break

    if not is_hidden and name and entry["exec"]:
        entries[name] = entry
        names.append(name)
        sys.stdout.write(name + "\t" + f"({filename.split('/')[-1]})" + "\t" + filename + "\n")

