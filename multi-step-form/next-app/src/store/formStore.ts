import { create } from 'zustand';
import { PersonalInfoData, PlanData, AddOnData, FormData } from '@/types/form';

interface FormState extends FormData {
  setPersonalInfo: (data: Partial<PersonalInfoData>) => void;
  setPlan: (data: Partial<PlanData>) => void;
  updateAddOn: (id: string, selected: boolean) => void;
  selectAddOns: (addOns: AddOnData[]) => void; // If you want to set multiple add-ons at once
  setCurrentStep: (step: number) => void;
  resetForm: () => void; // To reset the form to initial state
}

const initialPersonalInfo: PersonalInfoData = {
  name: '',
  email: '',
  phoneNumber: '',
};

const initialPlan: PlanData = {
  type: null,
  billing: 'monthly', // Default to monthly, can be changed
  price: 0,
};

const initialAddOns: AddOnData[] = [
  // Define your available add-ons here, e.g.:
  // { id: 'online-service', name: 'Online service', priceMonthly: 1, priceYearly: 10, selected: false },
  // { id: 'larger-storage', name: 'Larger storage', priceMonthly: 2, priceYearly: 20, selected: false },
  // { id: 'custom-profile', name: 'Customizable Profile', priceMonthly: 2, priceYearly: 20, selected: false },
];


const initialState: FormData = {
  personalInfo: initialPersonalInfo,
  plan: initialPlan,
  addOns: initialAddOns,
  currentStep: 1,
};

export const useFormStore = create<FormState>((set) => ({
  ...initialState,

  setPersonalInfo: (data) =>
    set((state) => ({
      personalInfo: { ...state.personalInfo, ...data },
    })),

  setPlan: (data) =>
    set((state) => ({
      plan: { ...state.plan, ...data },
    })),

  updateAddOn: (id, selected) =>
    set((state) => ({
      addOns: state.addOns.map((addon) =>
        addon.id === id ? { ...addon, selected } : addon
      ),
    })),

  selectAddOns: (newAddOns) =>
    set(() => ({
        addOns: newAddOns,
    })),

  setCurrentStep: (step) => set({ currentStep: step }),

  resetForm: () => set(initialState),
})); 