resource.relative '@rel==./description.txt' into '@this'
# Uncomment this if you want to include a BML description
resource.relative '@rel==./description.bml' into '@this'

@namespace
description() {
    echo "$(@this.resource.get './description.txt')"
}

# Uncomment this if you want to include a BML description
descriptionBml() {
    bml.print --text "$(@this.resource.get './description.bml')"
}