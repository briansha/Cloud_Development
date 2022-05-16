echo "Build the applet - Usage: ./0_build_applet.sh [DNANexus destination path]"
DESTINATION=$1
dx build mutect_50_samples_orientation --destination "${DESTINATION}" --overwrite

# Example destination path
#workflows/mutect2/
