#
# The MIT License
# Copyright (c) 2015 Estonian Information System Authority (RIA), Population Register Centre (VRK)
#
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#

java_import Java::ee.ria.xroad.common.DiagnosticsStatus
java_import Java::ee.ria.xroad.common.DiagnosticsErrorCodes
java_import Java::ee.ria.xroad.common.util.JsonUtils
java_import Java::ee.ria.xroad.common.PortNumbers

class DiagnosticsController < ApplicationController

  def index
    logger.info("Diagnostics index")
    authorize!(:diagnostics)
    prepare_confclient_ui
    prepare_timestamper_ui
  end

  def prepare_timestamper_ui
    response = query_timestamper_status
    if response != nil
      returnCode = response.getReturnCode()
      @timestamperStatusMessage = get_confclient_status_message(returnCode)
      if returnCode == DiagnosticsErrorCodes::RETURN_SUCCESS
        @timestamperStatusClass = "diagnostics_status_ok"
      elsif returnCode == DiagnosticsErrorCodes::ERROR_CODE_TIMESTAMP_UNINITIALIZED
        @timestamperStatusClass = "diagnostics_status_waiting"
      else
        @timestamperStatusClass = "diagnostics_status_fail"
      end
      @timestamperPrevUpdate = response.getFormattedPrevUpdate()
      @timestamperNextUpdate = response.getFormattedNextUpdate()
    else
      @timestamperStatusMessage = t('diagnostics.error_code_connection_failed')
      @timestamperStatusClass = "diagnostics_status_fail"
      @timestamperPrevUpdate = ""
      @timestamperNextUpdate = ""
    end
  end

  def prepare_confclient_ui
    response = query_confclient_status
    if response != nil
      returnCode = response.getReturnCode()
      @globalConfStatusMessage = get_confclient_status_message(returnCode)
      if returnCode == DiagnosticsErrorCodes::RETURN_SUCCESS
        @globalConfStatusClass = "diagnostics_status_ok"
      elsif returnCode == DiagnosticsErrorCodes::ERROR_CODE_UNINITIALIZED
        @globalConfStatusClass = "diagnostics_status_waiting"
      else
        @globalConfStatusClass = "diagnostics_status_fail"
      end
      @globalConfPrevUpdate = response.getFormattedPrevUpdate()
      @globalConfNextUpdate = response.getFormattedNextUpdate()
    else
      @globalConfStatusMessage = t('diagnostics.error_code_connection_failed')
      @globalConfStatusClass = "diagnostics_status_fail"
      @globalConfPrevUpdate = ""
      @globalConfNextUpdate = ""
    end
  end

  def query_confclient_status
    logger.info("Query configuration client status")

    port = SystemProperties::getConfigurationClientPort() + 1
    uri = URI("http://localhost:#{port}/status")

    response = nil

    begin
      response = Net::HTTP.get_response(uri)
      logger.info("Response code: " + response.code + " message: " + response.message + " body: " + response.body)
    rescue
      log_stacktrace($!)
      return nil
    end

    if response.code == '500'
      logger.error(response.body)
      return nil
    end

    gson = JsonUtils::getSerializer()
    return gson.fromJson(response.body, DiagnosticsStatus.java_class)
  end

  def query_timestamper_status
    logger.info("Query timestamper status")

    port = PortNumbers::ADMIN_PORT
    uri = URI("http://localhost:#{port}/timestampstatus")

    response = nil

    begin
      response = Net::HTTP.get_response(uri)
      logger.info("Response code: " + response.code + " message: " + response.message + " body: " + response.body)
    rescue
      log_stacktrace($!)
      return nil
    end

    if response.code == '500'
      logger.error(response.body)
      return nil
    end

    gson = JsonUtils::getSerializer()
    return gson.fromJson(response.body, DiagnosticsStatus.java_class)
  end

  private

  def get_confclient_status_message (returnCode)
    case
      when returnCode == DiagnosticsErrorCodes::RETURN_SUCCESS
        t('diagnostics.return_success')
      when returnCode == DiagnosticsErrorCodes::ERROR_CODE_INTERNAL
        t('diagnostics.error_code_internal')
      when returnCode == DiagnosticsErrorCodes::ERROR_CODE_INVALID_SIGNATURE_VALUE
        t('diagnostics.error_code_invalid_signature_value')
      when returnCode == DiagnosticsErrorCodes::ERROR_CODE_EXPIRED_CONF
        t('diagnostics.error_code_expired_conf')
      when returnCode == DiagnosticsErrorCodes::ERROR_CODE_CANNOT_DOWNLOAD_CONF
        t('diagnostics.error_code_cannot_download_conf')
      when returnCode == DiagnosticsErrorCodes::ERROR_CODE_MISSING_PRIVATE_PARAMS
        t('diagnostics.error_code_missing_private_params')
      when returnCode == DiagnosticsErrorCodes::ERROR_CODE_TIMESTAMP_REQUEST_TIMED_OUT
        t('diagnostics.error_code_timestamp_request_timed_out')
      when returnCode == DiagnosticsErrorCodes::ERROR_CODE_MALFORMED_TIMESTAMP_SERVER_URL
        t('diagnostics.error_code_malformed_timestamp_server_url')
      when returnCode == DiagnosticsErrorCodes::ERROR_CODE_UNINITIALIZED
        t('diagnostics.error_code_uninitialized')
      when returnCode == DiagnosticsErrorCodes::ERROR_CODE_TIMESTAMP_UNINITIALIZED
        t('diagnostics.error_code_timestamp_uninitialized')
      else
        t('diagnostics.error_code_unknown')
    end
  end

end