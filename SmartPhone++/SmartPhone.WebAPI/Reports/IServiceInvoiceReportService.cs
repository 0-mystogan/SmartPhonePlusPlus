using SmartPhone.Model.Responses;

namespace SmartPhone.WebAPI.Reports
{
    public interface IServiceInvoiceReportService
    {
        byte[] Generate(ServiceInvoiceResponse invoice);
    }
}


