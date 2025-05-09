# spec/cron_schedule_spec.rb
require 'test_helper'
require 'sidekiq/cron'

class CronScheduleTest < ActionController::TestCase
  def setup
    @schedule_loader = Sidekiq::Cron::ScheduleLoader.new
    @all_jobs = Sidekiq::Cron::Job.all
  end

  # Confirms that `config.cron_schedule_file` points to a real file.
  test "has a schedule file" do
    assert schedule_loader.has_schedule_file?
  end

  # Confirms that no jobs in the schedule have an invalid cron string.
  test "does not return any errors" do
    assert_empty schedule_loader.load
  end

  # May be subject to churn, but adds confidence.
  test "adds the expected number of jobs" do
    schedule_loader.load
    assert_equal 1, all_jobs.size
  end

  # Confirms that all job classes exist.
  test "has a valid class for each added job" do
    schedule_loader.load

    # Shows that all classes exist (as we can constantize the names without raising).
    all_jobs.each do |job|
      job_class = job.klass.constantize

      # Naive check that classes are sidekiq jobs (as they all have `.perfrom_async`).
      assert_respond_to :perform_async, job_class
    end
  end
end
