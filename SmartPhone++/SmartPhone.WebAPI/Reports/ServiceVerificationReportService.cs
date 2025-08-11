using System;
using System.Globalization;
using QuestPDF.Fluent;
using QuestPDF.Helpers;
using QuestPDF.Infrastructure;
using SmartPhone.Model.Responses;

namespace SmartPhone.WebAPI.Reports
{
    public class ServiceVerificationReportService : IServiceVerificationReportService
    {
        public byte[] Generate(ServiceVerificationResponse verification)
        {
            if (verification == null)
                throw new ArgumentNullException(nameof(verification));

            QuestPDF.Settings.License = LicenseType.Community;

            var document = Document.Create(container =>
            {
                container.Page(page =>
                {
                    page.Margin(30);

                    page.Header().Row(row =>
                    {
                        row.RelativeItem().Column(col =>
                        {
                            col.Item().Text("Service Verification").SemiBold().FontSize(20);
                            col.Item().Text($"Service ID: {verification.ServiceId:0000}");
                            col.Item().Text($"Created: {verification.CreatedAt:yyyy-MM-dd HH:mm}");
                        });
                    });

                    page.Content().Column(col =>
                    {
                        col.Spacing(10);

                        col.Item().Text($"Name: {verification.Name}");
                        if (!string.IsNullOrWhiteSpace(verification.Description))
                            col.Item().Text($"Description: {verification.Description}");

                        col.Item().Text($"Service Fee: {verification.ServiceFee.ToString("C", CultureInfo.CurrentCulture)}");

                        if (!string.IsNullOrWhiteSpace(verification.CustomerNotes))
                            col.Item().Text($"Customer Notes: {verification.CustomerNotes}");

                        col.Item().Text($"Customer: {verification.CustomerName}");
                        col.Item().Text($"Technician: {(string.IsNullOrWhiteSpace(verification.TechnicianName) ? "Unassigned" : verification.TechnicianName)}");

                        if (verification.EstimatedCompletion.HasValue)
                            col.Item().Text($"Approximate Completion: {verification.EstimatedCompletion:yyyy-MM-dd HH:mm}");

                        col.Item().PaddingTop(15).Text("This document confirms that the above service has been scheduled and will be processed as soon as possible.");
                    });

                    page.Footer().AlignCenter().Text("SmartPhone++ Service Center");
                });
            });

            using var stream = new System.IO.MemoryStream();
            document.GeneratePdf(stream);
            return stream.ToArray();
        }
    }
}


