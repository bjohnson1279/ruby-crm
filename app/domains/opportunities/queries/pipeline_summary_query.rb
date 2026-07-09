# app/domains/opportunities/queries/pipeline_summary_query.rb
module Opportunities
  class PipelineSummaryQuery
    Result = Data.define(
      :total_value,
      :weighted_value,
      :opportunity_count,
      :stages,
      :advisors
    )

    StageSummary = Data.define(:stage, :total_value, :weighted_value, :count)
    AdvisorSummary = Data.define(:user_id, :user_name, :total_value, :weighted_value, :count)

    def self.call(firm_id:)
      # Global aggregates for active opportunities
      summary_sql = <<~SQL
        SELECT 
          COALESCE(SUM(amount), 0) AS total_value,
          COALESCE(SUM(amount * probability / 100.0), 0) AS weighted_value,
          COUNT(id) AS opportunity_count
        FROM opportunities
        WHERE firm_id = ? AND stage NOT IN ('closed_won', 'closed_lost')
      SQL

      sanitized_summary = ActiveRecord::Base.sanitize_sql_array([summary_sql, firm_id])
      summary_row = ActiveRecord::Base.connection.exec_query(sanitized_summary).first

      # Aggregate by Stage (all opportunities)
      stage_sql = <<~SQL
        SELECT 
          stage,
          COALESCE(SUM(amount), 0) AS total_value,
          COALESCE(SUM(amount * probability / 100.0), 0) AS weighted_value,
          COUNT(id) AS stage_count
        FROM opportunities
        WHERE firm_id = ?
        GROUP BY stage
        ORDER BY stage_count DESC
      SQL

      sanitized_stages = ActiveRecord::Base.sanitize_sql_array([stage_sql, firm_id])
      stage_rows = ActiveRecord::Base.connection.exec_query(sanitized_stages)

      stages = stage_rows.map do |row|
        StageSummary.new(
          stage: row["stage"],
          total_value: BigDecimal(row["total_value"].to_s),
          weighted_value: BigDecimal(row["weighted_value"].to_s),
          count: row["stage_count"].to_i
        )
      end

      # Aggregate by Advisor (active opportunities only)
      advisor_sql = <<~SQL
        SELECT 
          o.user_id,
          u.name AS user_name,
          COALESCE(SUM(o.amount), 0) AS total_value,
          COALESCE(SUM(o.amount * o.probability / 100.0), 0) AS weighted_value,
          COUNT(o.id) AS advisor_count
        FROM opportunities o
        JOIN users u ON u.id = o.user_id
        WHERE o.firm_id = ? AND o.stage NOT IN ('closed_won', 'closed_lost')
        GROUP BY o.user_id, u.name
        ORDER BY total_value DESC
      SQL

      sanitized_advisors = ActiveRecord::Base.sanitize_sql_array([advisor_sql, firm_id])
      advisor_rows = ActiveRecord::Base.connection.exec_query(sanitized_advisors)

      advisors = advisor_rows.map do |row|
        AdvisorSummary.new(
          user_id: row["user_id"].to_i,
          user_name: row["user_name"],
          total_value: BigDecimal(row["total_value"].to_s),
          weighted_value: BigDecimal(row["weighted_value"].to_s),
          count: row["advisor_count"].to_i
        )
      end

      Result.new(
        total_value: BigDecimal(summary_row["total_value"].to_s),
        weighted_value: BigDecimal(summary_row["weighted_value"].to_s),
        opportunity_count: summary_row["opportunity_count"].to_i,
        stages: stages,
        advisors: advisors
      )
    end
  end
end
