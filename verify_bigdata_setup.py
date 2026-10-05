from bigdata_platform import configure_bigdata_env, get_spark_session


def main():
    info = configure_bigdata_env()
    spark = get_spark_session("PaintTradeVerify")
    count = spark.range(10).count()
    print("Big-data runtime ready")
    print(info)
    print({"spark_version": spark.version, "probe_count": count})
    spark.stop()


if __name__ == "__main__":
    main()
