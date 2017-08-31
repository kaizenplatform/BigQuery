require 'minitest/autorun'
require 'yaml'
require 'bigquery'

class BigQueryTest < MiniTest::Test
  def setup
    config = File.expand_path(File.dirname(__FILE__) + "/../.bigquery_settings.yml")
    @bq = BigQuery.new(YAML.load_file(config))
  end

  def test_for_tables
    tables = @bq.tables
    
    assert_equal "bigquery#table", tables[0]['kind']
  end

  def test_for_table_exists?
    a_table_id = @bq.tables[0]['tableReference']['tableId'].to_s
    assert_equal true, @bq.table_exists?(a_table_id)
    assert_equal false, @bq.table_exists?('test_table_not_exsist')
  end

  def test_for_query
    result = @bq.query("#standardSQL\nSELECT stn FROM `bigquery-public-data.noaa_gsod.gsod1929` LIMIT 1")

    assert_equal "bigquery#queryResponse", result['kind']
    assert_equal true, result['jobComplete']
    assert_equal true, result.has_key?("totalBytesProcessed")
    assert_equal true, result.has_key?("rows")
  end

  def test_for_datadets
    datasets = @bq.datasets
    assert_equal "bigquery#dataset", datasets[0]['kind']
  end

  def test_for_query_job
    result = @bq.query_job("#standardSQL\nSELECT stn FROM `bigquery-public-data.noaa_gsod.gsod1929` LIMIT 1")

    assert_equal "bigquery#queryResponse", result['kind']
    assert_equal true, result['jobComplete']
    assert_equal true, result.has_key?("totalBytesProcessed")
    assert_equal true, result.has_key?("rows")
  end

  def test_for_query_job_with_opt
    result = @bq.query_job("#standardSQL\nSELECT stn FROM `bigquery-public-data.noaa_gsod.gsod1929` LIMIT 1", {dryRun: true})
    # {"kind"=>"bigquery#queryResponse", "jobReference"=>{"projectId"=>"kaizen-analytics"}, "totalBytesProcessed"=>"16648", "jobComplete"=>true, "cacheHit"=>true}
    assert_equal "bigquery#queryResponse", result['kind']
    assert_equal true, result['jobComplete']
    assert_equal true, result.has_key?("totalBytesProcessed")
    assert_equal false, result.has_key?("rows")
  end

  def test_for_query_job_error
    result = @bq.query_job("#standardSQL\nSELECT stn FROM `bigquery-public-data.noaa_gsod.not_exists_table` LIMIT 1")

    assert_equal true, result.has_key?('error')
    assert_equal "Not found: Table bigquery-public-data:noaa_gsod.not_exists_table", result['error']['errors'][0]['message']
    assert_equal false, result.has_key?("totalBytesProcessed")
    assert_equal false, result.has_key?("rows")
  end

  # def test_timeout_error
  #   sleep(60 * 60)

  #   result = @bq.query("SELECT u FROM [test.test_table] LIMIT 1 asdlfjhasdlkfjhasdlkfklajh")
  #   puts result.inspect
  #   assert_equal result['error'], "bigquery#queryResponse"
  #   assert_equal result['jobComplete'], true
  # end
end

class BigQueryWithStubTest < MiniTest::Test
  def setup
    config = File.expand_path(File.dirname(__FILE__) + "/../.bigquery_settings.yml")
    @bq = BigQuery.new(YAML.load_file(config))
    @bq.define_singleton_method(:api) do |opts|
      case opts[:api_method].id
      when 'bigquery.jobs.query'
        case opts[:body_object]['query']
        when "SELECT id FROM table"
          {
            "kind"=>"bigquery#queryResponse",
            "schema"=>{"fields"=>[{"name"=>"stn", "type"=>"STRING", "mode"=>"NULLABLE"}]},
            "jobReference"=>{"projectId"=>"hoge", "jobId"=>"job_kDtyqQ0C_kVTwX0CxPvoZwEwrn43"},
            "totalRows"=>"1",
            "rows"=>[{"f"=>[{"v"=>"030050"}]}],
            "totalBytesProcessed"=>"123",
            "jobComplete"=>true,
            "cacheHit"=>false,
          }
        when "SELECT id FROM error_table"
          {
            "error"=>{
              "errors"=>[
                {"domain"=>"global", "reason"=>"notFound", "message"=>"Not found: Table bigquery-public-data:noaa_gsod.not_exists_table"}
              ],
              "code"=>404,
              "message"=>"Not found: Table bigquery-public-data:noaa_gsod.not_exists_table"
            }
          }
        when "SELECT id FROM big_size_table"
          {
            "kind"=>"bigquery#queryResponse",
            "jobReference"=>{"projectId"=>"hoge", "jobId"=>"job_nEemXWciSuKsjsbEJFSJ-HWxH3Ze"},
             "jobComplete"=>false
          }
        end
      when "bigquery.jobs.getQueryResults"
        {
          "kind"=>"bigquery#getQueryResultsResponse",
          "etag"=>"\"qaujFrjMT9Vbhl4LPdRuJLP1c20/lWJb2yhnp8r_WY0oVeePVNMIbBc\"",
          "schema"=>{"fields"=>[{"name"=>"title", "type"=>"STRING", "mode"=>"NULLABLE"}]},
          "jobReference"=>{"projectId"=>"hoge", "jobId"=>"job_U-t3r9TXaImI8qM-fEUXmz8_fOWD"},
          "totalRows"=>"1",
          "rows"=>[{"f"=>[{"v"=>"File talk:Svenska Scoutrådet.png"}]}],
          "totalBytesProcessed"=>"7294285723",
          "jobComplete"=>true,
          "cacheHit"=>false
        }
      end
    end
  end

  def test_for_query
    result = @bq.query("SELECT id FROM table")

    assert_equal false, result.has_key?('error')
    assert_equal "bigquery#queryResponse", result['kind']
    assert_equal "123", result['totalBytesProcessed']
    assert_equal true, result['jobComplete']
    assert_equal true, result.has_key?('rows')
    assert_equal true, result.has_key?('schema')
  end

  def test_for_query_job
    result = @bq.query_job("SELECT id FROM table")

    assert_equal false, result.has_key?('error')
    assert_equal "bigquery#queryResponse", result['kind']
    assert_equal "123", result['totalBytesProcessed']
    assert_equal true, result['jobComplete']
    assert_equal true, result.has_key?('rows')
    assert_equal true, result.has_key?('schema')
  end

  def test_for_query_job_big_size_job
    result = @bq.query_job("SELECT id FROM big_size_table")

    assert_equal false, result.has_key?('error')
    assert_equal "bigquery#getQueryResultsResponse", result['kind']
    assert_equal "7294285723", result['totalBytesProcessed']
    assert_equal true, result['jobComplete']
    assert_equal true, result.has_key?('rows')
    assert_equal true, result.has_key?('schema')
  end

  def test_for_query_job_error
    result = @bq.query_job("SELECT id FROM error_table")

    assert_equal true, result.has_key?('error')
    assert_equal false, result.has_key?('jobComplete')
    assert_equal false, result.has_key?('totalBytesProcessed')
    assert_equal "Not found: Table bigquery-public-data:noaa_gsod.not_exists_table", result['error']['errors'][0]['message']
    assert_equal false, result.has_key?('rows')
    assert_equal false, result.has_key?('schema')
  end

end
