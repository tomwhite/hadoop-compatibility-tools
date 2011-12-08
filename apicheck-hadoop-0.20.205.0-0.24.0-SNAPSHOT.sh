BASELINE_VERSION=0.20.205.0
NEW_VERSION=0.24.0-SNAPSHOT

cat hadoop_private_elements hadoop_hidden_classes <(cat hadoop_false_positives | grep -v '#') > excludes

./apicheck.sh \
  --project=hadoop \
  --package=org.apache.hadoop \
  --baseline-version=$BASELINE_VERSION \
  --baseline-tar=http://archive.apache.org/dist/hadoop/core/hadoop-$BASELINE_VERSION/hadoop-${BASELINE_VERSION}.tar.gz \
  --baseline-dir=hadoop-${BASELINE_VERSION} \
  --baseline-classpath-includes='{hadoop-core-$BASELINE_VERSION.jar,lib/*.jar,lib/jsp-2.1/*.jar}' \
  --baseline-classpath-excludes='lib/hadoop-fairscheduler-$BASELINE_VERSION.jar' \
  --new-version=$NEW_VERSION \
  --new-tar=file:///Users/tom/workspace/hadoop-trunk/hadoop-dist/target/hadoop-$NEW_VERSION.tar.gz \
  --new-classpath-includes='{share/hadoop/common/hadoop-common-$NEW_VERSION.jar,share/hadoop/hdfs/hadoop-hdfs-$NEW_VERSION.jar,share/hadoop/{common,hdfs}/lib/*.jar,lib/*.jar,modules/*.jar}' \
  --new-classpath-excludes='lib/hadoop-fairscheduler-$NEW_VERSION.jar' \
  --excluded-annotations='org.apache.hadoop.classification.InterfaceAudience$Private,org.apache.hadoop.classification.InterfaceAudience$LimitedPrivate,org.apache.hadoop.classification.InterfaceStability$Unstable' \
  --excludes-file=excludes \
  --hadoop-annotation-tools-jar=lib/* \
  --java-tools-classpath=$JAVA_HOME/../Classes/classes.jar:$JAVA_HOME/../Classes/jsse.jar:$JAVA_HOME/../Classes/jce.jar:$ANT_HOME/lib/ant.jar