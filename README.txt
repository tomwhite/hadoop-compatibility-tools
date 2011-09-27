Scripts for running SigTest (http://sigtest.java.net/) against different
versions of Hadoop projects to generate an API compatibility report.

To run the SigTest API compatibility check, run one of the api-check scripts.

Hadoop private and unstable API elements are excluded from the report using
a classfile analyzer hosted at https://github.com/tomwhite/hadoop-annotation-tools

The JARs from hadoop-annotation-tools are installed in lib, but can be updated 
as follows if needed:

% git clone git://github.com/tomwhite/hadoop-annotation-tools.git
% cd hadoop-annotation-tools
% mvn dependency:copy-dependencies -DoutputDirectory=/path/to/lib

Since the 0.20.x APIs lack audience and stability annotations a static list of
files is used instead - see hadoop_private_elements.

