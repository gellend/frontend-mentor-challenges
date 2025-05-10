// next-app/src/app/form/[stepId]/page.tsx
// Placeholder for form step components
const YourInfoStep = () => <div>Formulir Informasi Anda</div>;
const SelectPlanStep = () => <div>Pilih Paket Langganan</div>;
const AddOnsStep = () => <div>Pilih Tambahan</div>;
const SummaryStep = () => <div>Ringkasan Pesanan</div>;

export default function FormStepPage({ params }: { params: { stepId: string } }) {
  const { stepId } = params;

  const renderStepContent = () => {
    switch (stepId) {
      case 'your-info':
        return <YourInfoStep />;
      case 'select-plan':
        return <SelectPlanStep />;
      case 'add-ons':
        return <AddOnsStep />;
      case 'summary':
        return <SummaryStep />;
      default:
        return <div>Langkah tidak valid atau halaman utama form.</div>;
    }
  };

  return (
    <div>
      <h2>Langkah: {stepId.replace('-', ' ').toUpperCase()}</h2>
      {renderStepContent()}
      {/* Navigation buttons will be added here later */}
    </div>
  );
} 