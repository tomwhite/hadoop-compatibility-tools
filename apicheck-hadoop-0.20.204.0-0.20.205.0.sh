BASELINE_VERSION=0.20.204.0
NEW_VERSION=0.20.205.0

cat hadoop_private_elements hadoop_hidden_classes > excludes

./apicheck.sh \
  --project=hadoop \
  --package=org.apache.hadoop \
  --baseline-version=$BASELINE_VERSION \
  --baseline-tar=http://archive.apache.org/dist/hadoop/core/hadoop-$BASELINE_VERSION/hadoop-${BASELINE_VERSION}.tar.gz \
  --baseline-dir=hadoop-${BASELINE_VERSION} \
  --baseline-classpath-includes='{hadoop-core-$BASELINE_VERSION.jar,lib/*.jar,lib/jsp-2.1/*.jar}' \
  --baseline-classpath-excludes='lib/hadoop-fairscheduler-$BASELINE_VERSION.jar' \
  --new-version=$NEW_VERSION \
  --new-tar=http://people.apache.org/~mattf/hadoop-0.20.205.0-rc2/hadoop-0.20.205.0.tar.gz \
  --new-dir=hadoop-${NEW_VERSION} \
  --new-classpath-includes='{hadoop-core-$NEW_VERSION.jar,lib/*.jar,lib/jsp-2.1/*.jar}' \
  --new-classpath-excludes='lib/hadoop-fairscheduler-$NEW_VERSION.jar' \
  --excluded-annotations='org.apache.hadoop.classification.InterfaceAudience$Private,org.apache.hadoop.classification.InterfaceAudience$LimitedPrivate,org.apache.hadoop.classification.InterfaceStability$Unstable' \
  --excludes-file=excludes \
  --hadoop-annotation-tools-jar=lib/* \
  --java-tools-classpath=$JAVA_HOME/../Classes/classes.jar:$JAVA_HOME/../Classes/jsse.jar:$JAVA_HOME/../Classes/jce.jar:$ANT_HOME/lib/ant.jar
