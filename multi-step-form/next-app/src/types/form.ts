// next-app/src/types/form.ts
export interface PersonalInfoData {
  name: string;
  email: string;
  phoneNumber: string;
}

export interface PlanData {
  type: 'arcade' | 'advanced' | 'pro' | null;
  billing: 'monthly' | 'yearly' | null;
  price: number;
}

export interface AddOnData {
  id: string;
  name: string;
  priceMonthly: number;
  priceYearly: number;
  selected: boolean;
}

export interface FormData {
  personalInfo: PersonalInfoData;
  plan: PlanData;
  addOns: AddOnData[];
  currentStep: number; // For tracking the active step globally if needed
} 