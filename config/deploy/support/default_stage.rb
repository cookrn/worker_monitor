if CONFIG.deploy_default_stage
  default_stage = CONFIG.deploy_default_stage
else
  stages = fetch :stages
  if stages.size == 1
    default_stage = stages[ 0 ]
  else
    raise "Uhoh! Unable to determine a default stage."
  end
end

set :default_stage , default_stage
