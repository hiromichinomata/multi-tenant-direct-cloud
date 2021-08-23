require 'base64'

API_BASE_URL = 'https://api.directcloud.jp'

class InvoicesController < ApplicationController
  before_action :set_invoice, only: [:show, :edit, :update, :destroy]

  # GET /invoices
  def index
    @invoices = Invoice.all
  end

  # GET /invoices/1
  def show
    @preview_url = ''
    @preview_url = get_viewer_url(@invoice.file_seq) if @invoice.file_seq.present?
  end

  # GET /invoices/new
  def new
    @invoice = Invoice.new
  end

  # GET /invoices/1/edit
  def edit
  end

  # POST /invoices
  def create
    upload_file
    @invoice = Invoice.new(invoice_params)

    if @invoice.save
      redirect_to @invoice, notice: 'Invoice was successfully created.'
    else
      render :new
    end
  end

  # PATCH/PUT /invoices/1
  def update
    upload_file
    if @invoice.update(invoice_params)
      redirect_to @invoice, notice: 'Invoice was successfully updated.'
    else
      render :edit
    end
  end

  # DELETE /invoices/1
  def destroy
    @invoice.destroy
    redirect_to invoices_url, notice: 'Invoice was successfully destroyed.'
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_invoice
      @invoice = Invoice.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def invoice_params
      param_data = params.require(:invoice).permit(:title)
      param_data.merge({ filename: request.params[:invoice][:blob].original_filename })
    end

    def upload_file
      blob = request.params[:invoice][:blob]
      data = blob.tempfile.read
      base64_data = Base64.encode64(data)
      # upload file
    end

    def get_viewer_url(file_seq)
      token = get_access_token
      url = API_BASE_URL + '/openapp/v1/viewer/create'
      payload = { file_seq: file_seq }
      header = {
                  "Content-Type": "application/x-www-form-urlencoded",
                  "access_token": token
                }

      clnt = HTTPClient.new
      response = clnt.post(url, payload, header)
      JSON.parse(response.body)["url"]
    end

    def get_access_token
      url = API_BASE_URL + '/openapi/jauth/token?lang=eng'
      payload = {
                  service: ENV['DCB_SERVICE'],
                  service_key: ENV['DCB_SERVICE_KEY'],
                  code: ENV['DCB_COMPANY_CODE'],
                  id: ENV['DCB_SUPERUSER_CODE'],
                  password: ENV['DCB_PASSWORD']
                }
      response = Faraday.post(url) do |req|
        req.headers["Content-Type"] = "application/x-www-form-urlencoded"
        req.body = payload.to_query
      end
      JSON.parse(response.body)["access_token"]
    end
end
