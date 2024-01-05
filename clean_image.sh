#!/bin/bash
set -u
set -e

URL="https://raw.githubusercontent.com/elastic/elasticsearch/$BRANCH/x-pack/plugin/core/src/main/java/org/elasticsearch"

# Download source code
curl -o LicenseVerifier.java -s $URL/license/LicenseVerifier.java
curl -o XPackBuild.java -s $URL/xpack/core/XPackBuild.java

# Edit LicenseVerifier.java
sed -i '/.*PublicKey PUBLIC_KEY.*/i END\nCODE' LicenseVerifier.java
sed -i '/.*signedContent = null.*/i BEG' LicenseVerifier.java
sed -i '/BEG/,/END/d' LicenseVerifier.java
sed -i 's/CODE/            return true;\n    }\n/g' LicenseVerifier.java

# Edit XPackBuild.java
sed -i 's/path.toString().endsWith(".jar")/false/g' XPackBuild.java

# Build class files
/usr/share/elasticsearch/jdk/bin/javac -cp "/usr/share/elasticsearch/lib/*:/usr/share/elasticsearch/modules/x-pack-core/*" LicenseVerifier.java
/usr/share/elasticsearch/jdk/bin/javac -cp "/usr/share/elasticsearch/lib/*:/usr/share/elasticsearch/modules/x-pack-core/*" XPackBuild.java

# Build jar file
cp /usr/share/elasticsearch/modules/x-pack-core/x-pack-core-$VERSION.jar x-pack-core.jar
unzip x-pack-core.jar -d ./x-pack-core
cp LicenseVerifier.class ./x-pack-core/org/elasticsearch/license/
cp XPackBuild.class ./x-pack-core/org/elasticsearch/xpack/core/
/usr/share/elasticsearch/jdk/bin/jar -cvf x-pack-core.jar -C x-pack-core .

# Clean temporary
rm -rf *.java x-pack-core
