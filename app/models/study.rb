class Study < ActiveRecord::Base
  unloadable
=begin
  def destroy
    logger.info "From delete method "
      study = Study.find_by_id(params[:id])
      study.destroy
      redirect_to "/studies/"
  end
=end
end
