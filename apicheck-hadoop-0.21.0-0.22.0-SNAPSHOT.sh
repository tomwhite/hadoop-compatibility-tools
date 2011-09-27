BASELINE_VERSION=0.21.0
NEW_VERSION=0.22.0-SNAPSHOT

./apicheck.sh \
  --project=hadoop \
  --package=org.apache.hadoop \
  --baseline-version=$BASELINE_VERSION \
  --baseline-tar=http://archive.apache.org/dist/hadoop/core/hadoop-$BASELINE_VERSION/hadoop-$BASELINE_VERSION.tar.gz \
  --baseline-classpath-includes='{hadoop-{common,hdfs,mapred}-$BASELINE_VERSION.jar,lib/*.jar}' \
  --baseline-classpath-excludes='lib/hadoop-fairscheduler-$BASELINE_VERSION.jar' \
  --new-version=$NEW_VERSION \
  --new-tar=https://builds.apache.org/view/G-L/view/Hadoop/job/Hadoop-22-Build/lastSuccessfulBuild/artifact/hadoop-$NEW_VERSION.tar.gz \
  --new-classpath-includes='{hadoop-{common,hdfs,mapred}-$NEW_VERSION.jar,lib/*.jar}' \
  --new-classpath-excludes='lib/hadoop-fairscheduler-$NEW_VERSION.jar' \
  --generate-excludes \
  --excluded-annotations='org.apache.hadoop.classification.InterfaceAudience$Private,org.apache.hadoop.classification.InterfaceAudience$LimitedPrivate,org.apache.hadoop.classification.InterfaceStability$Unstable,org.apache.hadoop.classification.InterfaceStability$Evolving' \
  --excludes-file=hadoop_hidden_classes \
  --hadoop-annotation-tools-jar=lib/* \
  --java-tools-classpath=$JAVA_HOME/../Classes/classes.jar:$JAVA_HOME/../Classes/jsse.jar:$JAVA_HOME/../Classes/jce.jar:$ANT_HOME/lib/ant.jar
