// next-app/src/app/form/[stepId]/page.tsx
import YourInfoStep from '@/components/form/YourInfoStep';
import SelectPlanStep from '@/components/form/SelectPlanStep';
import SelectAddOnsStep from '@/components/form/SelectAddOnsStep';
// const AddOnsStep = () => <div>Pilih Tambahan</div>;
// const SummaryStep = () => <div>Ringkasan Pesanan</div>;

export default function FormStepPage({ params }: { params: { stepId: string } }) {
  const { stepId } = params;

  const renderStepContent = () => {
    switch (stepId) {
      case 'your-info':
        return <YourInfoStep />;
      case 'select-plan':
        return <SelectPlanStep />;
      case 'add-ons':
        return <SelectAddOnsStep />;
      // case 'summary':
      //   return <SummaryStep />;
      default:
        // This case might be hit if the stepId is not one of the above
        // or if it's the base '/form' route (if you had one)
        return <div>Invalid step or form home. Current step: {stepId}</div>;
    }
  };

  return (
    <>
      {renderStepContent()}
    </>
  );
} 