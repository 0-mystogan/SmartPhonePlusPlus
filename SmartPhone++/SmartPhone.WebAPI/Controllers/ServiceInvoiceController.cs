using Microsoft.AspNetCore.Mvc;
using SmartPhone.Services.Interfaces;
using SmartPhone.WebAPI.Reports;
using System;
using System.Threading.Tasks;

namespace SmartPhone.WebAPI.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class ServiceInvoiceController : ControllerBase
    {
        private readonly IServiceService _serviceService;
        private readonly IServiceInvoiceReportService _reportService;

        public ServiceInvoiceController(IServiceService serviceService, IServiceInvoiceReportService reportService)
        {
            _serviceService = serviceService;
            _reportService = reportService;
        }

        [HttpGet("{id}")]
        public async Task<IActionResult> Get(int id)
        {
            try
            {
                var invoice = await _serviceService.GetInvoiceAsync(id);
                if (invoice == null)
                    return NotFound();

                var pdfBytes = _reportService.Generate(invoice);
                var fileName = $"Invoice_{invoice.InvoiceNumber}.pdf";
                return File(pdfBytes, "application/pdf", fileName);
            }
            catch (Exception ex)
            {
                if (ex.Message == "Service not found")
                    return NotFound();
                throw;
            }
        }
    }
}


