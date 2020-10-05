#!/usr/bin/env python


# Copyright (c) 2020, Unseen Bio ApS.
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.


"""Add taxonomy identifiers to HumGut genome FASTA records."""


import logging
import sys
from typing import Dict, List

import pandas as pd


logger = logging.getLogger(__name__)


def add_tax_id_to_header(header: str, mapping: Dict[str, str]) -> str:
    """"""
    id, description = header[1:].split(" ", 1)
    return f">{id}|kraken:taxid|{mapping[id.rsplit('_', 1)[0]]} {description}"


def main(argv: List[str]) -> None:
    """"""
    table = pd.read_table(argv[0])
    mapping = {
        i: str(t)
        for i, t in table[["centroid_genome_id", "tax_id"]].itertuples(
            index=False, name=None
        )
    }
    with open(argv[1]) as source, open(argv[2], "w") as target:
        content = []
        for line in source:
            if line.startswith(">"):
                content.append(add_tax_id_to_header(line, mapping))
            else:
                content.append(line)
        target.writelines(content)


if __name__ == "__main__":
    logging.basicConfig(level="INFO")
    if len(sys.argv) == 4:
        main(sys.argv[1:])
    else:
        print("Usage:")
        print(f"{sys.argv[0]} <table> <genome> <taxonomy id genome>")
