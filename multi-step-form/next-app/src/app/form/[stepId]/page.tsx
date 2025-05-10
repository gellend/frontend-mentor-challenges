// next-app/src/app/form/[stepId]/page.tsx
import YourInfoStep from '@/components/form/YourInfoStep';
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
      {renderStepContent()}
      {/* Navigation buttons will be added here later */}
    </div>
  );
} 