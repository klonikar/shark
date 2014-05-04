package shark.example.java;

import org.apache.hadoop.hive.metastore.MetaStoreUtils;
import org.apache.spark.api.java.JavaRDD;
import org.apache.spark.api.java.function.Function;

import shark.api.Row;
import shark.api.JavaSharkContext;
import shark.api.JavaTableRDD;
import shark.SharkEnv;
import shark.SharkContext;

// compile using:  javac -cp shark-0.8.0-bin-cdh4/shark-0.8.0/target/scala-2.9.3/shark_2.9.3-0.8.0.jar:spark-0.8.0/core/target/spark-core_2.9.3-0.8.0-incubating.jar:scala-2.9.3/lib/scala-library.jar:shark-0.8.0-bin-cdh4/hive-0.9.0-shark-0.8.0-bin/lib/hive-metastore-0.9.0-shark-0.8.0.jar Example1.java 
//
public class Example1 {
    public static void main(String[] args) {
        String defSparkMaster = "spark://localhost:7077";
	String defSharkVersion = "0.8.0";
        String METASTORE_PATH = System.getProperty("user.dir") + "/test_warehouses/" + "test-metastore";
        String WAREHOUSE_PATH = System.getProperty("user.dir") + "/test_warehouses/" + "test-warehouse";
        String master = System.getenv("MASTER");
        if(master == null || master.isEmpty())
            master = defSparkMaster;

        JavaSharkContext jsc = SharkEnv.initWithJavaSharkContext("shark_example1", master);
        // Needed when SPARK_CLASSPATH is not exported
        /*
        String sparkClasspath = System.getenv("SPARK_CLASSPATH");
        String[] classPathComponents = sparkClasspath.split(":");
        for(String comp : classPathComponents) {
            if(comp.equals("."))
                continue;
            jsc.addJar(comp);
        }
        */
	String version = System.getenv("SHARK_VERSION");
	if(version == null || version.isEmpty())
	    version = defSharkVersion;
        jsc.runSql("set shark.test.data.path=" + System.getenv("SHARK_HOME") + "/shark-" + version + "/data/files");
        jsc.runSql("set javax.jdo.option.ConnectionURL=jdbc:derby:;databaseName=" +
                    METASTORE_PATH + ";create=true");
        jsc.runSql("set hive.metastore.warehouse.dir=" + WAREHOUSE_PATH);
        jsc.runSql("USE " + MetaStoreUtils.DEFAULT_DATABASE_NAME);
        jsc.sql("drop table if exists test_java");
        jsc.sql("CREATE TABLE test_java(key INT, val STRING)");
        jsc.sql("LOAD DATA LOCAL INPATH '${hiveconf:shark.test.data.path}/kv1.txt' INTO TABLE test_java");
        JavaTableRDD result = jsc.sql2rdd("select val from test_java");
        JavaRDD<String> values = result.map(new Function<Row, String>() {
             @Override
             public String call(Row x) {
                 System.out.println("val: " + x.getString(0)); // Can be seen on the stdout of workers
                 return x.getString(0);
             }
        });
        System.out.println("Total results: " + values.count()); // Can be seen on the stdout of the driver program

        jsc.stop();
        
    }
}

