#!/bin/bash

perl -p -i -e 's/<p class="SectionBreaksbr">.*?<\/p>/<\/section><section>/g' $1
perl -p -i -e 's/<\/section>?//' $1
perl -p -i -e 's/<\/section>/<\/section>\n/g' $1
perl -p -i -e 's/<\/p>/<\/p>\n/g' $1
#perl -p -i -e 's/<p class="PartStartpts">.*<\/p>/<div data-type="part">/g' $1
#perl -p -i -e 's/<p class="PartEndpte">.*<\/p>/<\/div>/g' $1