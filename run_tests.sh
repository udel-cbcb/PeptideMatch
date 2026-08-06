#!/usr/bin/env bash
#
# Compile and run the unit tests for the PeptideMatch modules.
#
# Usage:
#   ./run_tests.sh                      # compile and run all tests
#   ./run_tests.sh --cmd                # only the peptidematch_cmd module
#   ./run_tests.sh --async-rest-client  # only the async rest client module
#   ./run_tests.sh --index-data         # only the index_data module
#   ./run_tests.sh --web                # only the peptidematch_web module
#   ./run_tests.sh --ws                 # only the peptidematchws module
#
# The script requires a JDK and resolves dependencies from the local Maven
# repository. Override with JDK_HOME and M2_REPO if needed.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BUILD_DIR="$(mktemp -d /tmp/pm_tests.XXXXXX)"
trap 'rm -rf "$BUILD_DIR"' EXIT

JAVAC="${JDK_HOME:-/data/home/chenc/peptidesearch/jdk8u482}/bin/javac"
JAVA="${JDK_HOME:-/data/home/chenc/peptidesearch/jdk8u482}/bin/java"
M2_REPO="${M2_REPO:-$HOME/.m2/repository}"

JUNIT_JAR="$M2_REPO/junit/junit/4.13.2/junit-4.13.2.jar"
HAMCREST_JAR="$M2_REPO/org/hamcrest/hamcrest-core/1.3/hamcrest-core-1.3.jar"
JUNIT_CP="$JUNIT_JAR:$HAMCREST_JAR"

LUCENE46="$M2_REPO/org/apache/lucene/lucene-core/4.6.0/lucene-core-4.6.0.jar:$M2_REPO/org/apache/lucene/lucene-analyzers-common/4.6.0/lucene-analyzers-common-4.6.0.jar:$M2_REPO/org/apache/lucene/lucene-queryparser/4.6.0/lucene-queryparser-4.6.0.jar"
COMMONS_CLI="$M2_REPO/commons-cli/commons-cli/1.2/commons-cli-1.2.jar"
COMMONS_IO="$M2_REPO/commons-io/commons-io/2.4/commons-io-2.4.jar"
LUCENE35="$M2_REPO/org/apache/lucene/lucene-core/3.5.0/lucene-core-3.5.0.jar:$M2_REPO/org/apache/lucene/lucene-analyzers/3.5.0/lucene-analyzers-3.5.0.jar"
JAXB="$M2_REPO/javax/xml/bind/jaxb-api/2.3.1/jaxb-api-2.3.1.jar"
WSRS="$M2_REPO/javax/ws/rs/javax.ws.rs-api/2.0.1/javax.ws.rs-api-2.0.1.jar"
JERSEY1="$M2_REPO/com/sun/jersey/jersey-client/1.19/jersey-client-1.19.jar:$M2_REPO/com/sun/jersey/jersey-core/1.19/jersey-core-1.19.jar:$M2_REPO/com/sun/jersey/contribs/jersey-apache-client/1.13/jersey-apache-client-1.13.jar:$M2_REPO/com/sun/jersey/jersey-json/1.19/jersey-json-1.19.jar"
JACKSON="$M2_REPO/com/fasterxml/jackson/core/jackson-databind/2.22.1/jackson-databind-2.22.1.jar:$M2_REPO/com/fasterxml/jackson/core/jackson-core/2.22.1/jackson-core-2.22.1.jar:$M2_REPO/com/fasterxml/jackson/core/jackson-annotations/2.22/jackson-annotations-2.22.jar"
HTTPCLIENT="$M2_REPO/commons-httpclient/commons-httpclient/3.1/commons-httpclient-3.1.jar:$M2_REPO/commons-logging/commons-logging/1.1.1/commons-logging-1.1.1.jar"

CMD_CP="$LUCENE46:$COMMONS_CLI:$COMMONS_IO"
ASYNCREST_CP="$JAXB:$WSRS:$HTTPCLIENT:$JACKSON:$JERSEY1"
INDEXDATA_CP="$LUCENE35"
WEB_CP="$LUCENE35"
WS_CP="$JAXB"

failures=0

run_module() {
    local name="$1" src_cp="$2" test_src="$3" classes_out="$4" test_out="$5" main_srcs="$6" tests="$7"
    echo "== $name =="
    local main_out="$BUILD_DIR/$classes_out"
    local test_out_dir="$BUILD_DIR/$test_out"
    mkdir -p "$main_out" "$test_out_dir"

    if [ -n "$main_srcs" ]; then
        "$JAVAC" -nowarn -d "$main_out" -cp "$src_cp" $main_srcs 2> /tmp/pm_main_err.txt || {
            echo "  FAILED to compile $name main sources:"; cat /tmp/pm_main_err.txt; failures=$((failures + 1)); return 1;
        }
    fi

    "$JAVAC" -nowarn -d "$test_out_dir" -cp "$src_cp:$JUNIT_CP:$main_out" $(find "$test_src" -name "*.java") 2> /tmp/pm_test_err.txt || {
        echo "  FAILED to compile $name tests:"; cat /tmp/pm_test_err.txt; failures=$((failures + 1)); return 1;
    }

    if ! "$JAVA" -cp "$src_cp:$JUNIT_CP:$test_out_dir:$main_out" org.junit.runner.JUnitCore $tests; then
        failures=$((failures + 1))
    fi
}

run_cmd() {
    run_module "peptidematch_cmd" "$CMD_CP" \
        "$SCRIPT_DIR/peptidematch_cmd/test" cmd_classes cmd_test \
        "$(find "$SCRIPT_DIR/peptidematch_cmd/src" -name '*.java')" \
        "org.proteininformationresource.PeptideMatch.FastaTest org.proteininformationresource.PeptideMatch.MatchedRangeTest org.proteininformationresource.PeptideMatch.NGramAnalyzerTest org.proteininformationresource.PeptideMatch.PeptideMatchCMDTest"
}

run_async_rest_client() {
    run_module "peptidematch_async_rest_client" "$ASYNCREST_CP" \
        "$SCRIPT_DIR/peptidematch_async_rest_client/src/test/java" asyncrest_classes asyncrest_test \
        "$(find "$SCRIPT_DIR/peptidematch_async_rest_client/src/main" -name '*.java')" \
        "org.proteininformationresource.peptidematch.asyncrest.model.QueryTest org.proteininformationresource.peptidematch.asyncrest.model.MatchTest"
}

run_index_data() {
    run_module "index_data" "$INDEXDATA_CP" \
        "$SCRIPT_DIR/index_data/test" indexdata_classes indexdata_test \
        "$SCRIPT_DIR/index_data/javaprogram/NGramAnalyzer.java $SCRIPT_DIR/index_data/javaprogram/NGramIndexer.java $SCRIPT_DIR/index_data/javaprogram/NumberUtils.java" \
        "javaprogram.NumberUtilsTest javaprogram.NGramIndexerTest javaprogram.NGramAnalyzerTest"
}

run_web() {
    run_module "peptidematch_web" "$WEB_CP" \
        "$SCRIPT_DIR/peptidematch_web/test" web_classes web_test \
        "$SCRIPT_DIR/peptidematch_web/WEB-INF/classes/org/proteininformationresource/peptidematch/MatchedRange.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/org/proteininformationresource/peptidematch/MatchedProtein.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/org/proteininformationresource/peptidematch/MatchResult.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/org/proteininformationresource/peptidematch/Organism.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/org/proteininformationresource/peptidematch/OrganismCount.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/org/proteininformationresource/peptidematch/Query.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/org/proteininformationresource/peptidematch/QueryPeptide.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/query/Tools.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/query/HighLight.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/query/TaxonomyTreeNode.java $SCRIPT_DIR/peptidematch_web/WEB-INF/classes/query/TaxonomyLazyTreeNode.java" \
        "org.proteininformationresource.peptidematch.OrganismTest org.proteininformationresource.peptidematch.MatchedRangeTest org.proteininformationresource.peptidematch.QueryPeptideTest org.proteininformationresource.peptidematch.QueryTest org.proteininformationresource.peptidematch.MatchedProteinTest query.ToolsTest query.HighLightTest query.TaxonomyTreeNodeTest query.TaxonomyLazyTreeNodeTest"
}

run_ws() {
    run_module "peptidematchws" "$WS_CP" \
        "$SCRIPT_DIR/peptidematchws/test" ws_classes ws_test \
        "$(find "$SCRIPT_DIR/peptidematchws/WEB-INF/classes/org/proteininformationresource/peptidematch/asyncrest/model" -maxdepth 1 -name '*.java')" \
        "org.proteininformationresource.peptidematch.asyncrest.model.QueryTest org.proteininformationresource.peptidematch.asyncrest.model.ModelTest"
}

if [ "$#" -eq 0 ]; then
    run_cmd
    run_async_rest_client
    run_index_data
    run_web
    run_ws
else
    case "$1" in
        --cmd) run_cmd ;;
        --async-rest-client) run_async_rest_client ;;
        --index-data) run_index_data ;;
        --web) run_web ;;
        --ws) run_ws ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
fi

echo
if [ "$failures" -eq 0 ]; then
    echo "All test modules passed."
else
    echo "$failures test module(s) had failures."
    exit 1
fi
