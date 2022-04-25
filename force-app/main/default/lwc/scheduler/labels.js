let Anonymous_code_job_prefix = "anonymous code";
let Anonymous_code_warning = "Anonymous code runs in user mode. You can only do what you have permission to do!";
let Batch_size = "What is the batch size? (leave blank to use the Salesforce default)";
let Batch_size_overflow = "Batch size must be between 1 and 2000.";
let Batch_size_underflow = "Batch size must be between 1 and 2000.";
let Code_remaining = "Characters remaining";
let Confirm = "Confirm";
let Daily_end_date = "Until when? (leave blank to run in perpetuity)";
let End_date_time = "Until when? (leave blank to run in perpetuity)";
let Enter_code = "Enter your anonymous code";
let Flow_retrieval_error = "There was an error retrieving flows.";
let Flow_warning =
  "You may not have permission to run all the listed flows. It is possible for System Adminstrator permissions to be removed from an individual flow.";
let Main_choice = "What do you want to schedule?";
let Main_choice_class = "A class";
let Main_choice_code = "Anonymous code";
let Main_choice_flow = "A flow";
let Max_code_entered = "You have entered the maximum amount of code";
let Repeat_interval = "How often (in minutes) would you like to repeat this job? (enter 0 to run once)";
let Repeat_interval_underflow = "Repeat interval must be zero or greater.";
let Required_field = "Complete this field.";
let Reschedule_interval =
  "How soon (in minutes) would you like to retry this job if the queue is full or if the batch job is not done executing?";
let Reschedule_interval_underflow = "Reschedule interval must be a positive whole number.";
let Schedule = "Schedule";
let Select_flow = "What flow would you like to schedule?";
let Start_again_the_next_day = "Run daily?";
let Start_date_time = "When would you like the job to start?";
let Start_time_passed = "Your start date &amp; time has passed!";
let Spinner_alt_text_loading = "Loading...";
let Spinner_alt_text_scheduling = "Scheduling...";
let Toast_success_message = "Job scheduled successfully!";
let Toast_success_title = "Success";
let View_Apex_jobs = "View Apex jobs";
let View_scheduled_jobs = "View Scheduled jobs";
export default {
  Anonymous_code_job_prefix,
  Anonymous_code_warning,
  Batch_size,
  Batch_size_overflow,
  Batch_size_underflow,
  Code_remaining,
  Confirm,
  End_date_time,
  Enter_code,
  Daily_end_date,
  Flow_retrieval_error,
  Flow_warning,
  Main_choice,
  Main_choice_class,
  Main_choice_code,
  Main_choice_flow,
  Max_code_entered,
  Repeat_interval,
  Repeat_interval_underflow,
  Required_field,
  Reschedule_interval,
  Reschedule_interval_underflow,
  Schedule,
  Select_flow,
  Start_again_the_next_day,
  Start_date_time,
  Start_time_passed,
  Spinner_alt_text_loading,
  Spinner_alt_text_scheduling,
  Toast_success_message,
  Toast_success_title,
  View_Apex_jobs,
  View_scheduled_jobs
};
