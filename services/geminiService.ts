import { GoogleGenAI } from "@google/genai";

// Safe helper to get API Key without crashing the browser if 'process' is undefined
const getApiKey = (): string => {
  try {
    return process.env.API_KEY || "";
  } catch (e) {
    return "";
  }
};

const apiKey = getApiKey();
const ai = apiKey ? new GoogleGenAI({ apiKey }) : null;

export const generateInvoiceNotes = async (customerName: string, itemsDescription: string): Promise<string> => {
  if (!ai) return "Thank you for choosing Clonmel Glass & Mirrors. Payment is due within 30 days of invoice date. All products come with our quality guarantee. For any queries, please contact us.";
  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: `You are writing professional invoice notes for Clonmel Glass & Mirrors, a premium glass and mirror installation company.

Customer: ${customerName}
Items ordered: ${itemsDescription}

Create comprehensive, professional invoice notes that include:
1. A warm, personalized thank you message acknowledging their specific order
2. Payment terms (e.g., "Payment is kindly requested within 30 days of invoice date")
3. A brief mention of quality assurance or warranty (e.g., "All products come with our quality guarantee")
4. Banking/payment instructions (e.g., "Bank transfer details are provided below" or "Multiple payment methods accepted")
5. A professional closing with contact information offer

Tone: Professional, warm, and customer-focused
Style: Well-structured with clear sections
Length: 4-6 sentences, well-formatted
Format: Use proper punctuation and paragraph breaks where appropriate.

Make it feel premium and trustworthy while being friendly and approachable.`,
    });
    const result = response.text;
    return typeof result === 'string' ? result : "Thank you for choosing Clonmel Glass & Mirrors. Payment is due within 30 days. All products come with our quality guarantee.";
  } catch (error) {
    console.error("Gemini API Error:", error);
    return "Thank you for your business! Payment is kindly requested within 30 days of invoice date. All our products come with a quality guarantee. For any queries, please don't hesitate to contact us.";
  }
};

export const generateReminderMessage = async (customerName: string, invoiceNum: string, balance: number, daysDifference: number): Promise<string> => {
  if (!ai) return `This is a reminder that a balance remains on Invoice ${invoiceNum}. Please settle this at your earliest convenience.`;
  try {
    let context = "";
    if (daysDifference < 0) {
      context = `is OVERDUE by ${Math.abs(daysDifference)} days. Be firm but professional.`;
    } else if (daysDifference === 0) {
      context = `is DUE TODAY. Be polite and remind them of the deadline.`;
    } else {
      context = `is UPCOMING in ${daysDifference} days. This is a proactive friendly reminder.`;
    }

    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: `Draft a payment reminder email for Clonmel Glass & Mirrors. 
      Customer: ${customerName}. 
      Invoice: ${invoiceNum}. 
      Balance Due: €${balance.toFixed(2)}. 
      Status: The payment ${context}
      Include a request for settlement. Max 3 sentences.`,
    });
    const result = response.text;
    return typeof result === 'string' ? result : `This is a reminder that a balance remains on Invoice ${invoiceNum}.`;
  } catch (error) {
    return `Reminder for Invoice ${invoiceNum}: Outstanding balance of €${balance.toFixed(2)} needs attention.`;
  }
};

export const generateProductDescription = async (productName: string): Promise<string> => {
  if (!ai) return "";
  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: `Write a short, attractive product description (max 20 words) for a glass/mirror product named "${productName}".`,
    });
    const result = response.text;
    return typeof result === 'string' ? result : "";
  } catch (error) {
    console.error("Gemini API Error:", error);
    return "";
  }
};

export const analyzeInvoiceTrends = async (invoicesSummary: string): Promise<string> => {
  if (!ai) return "No insights available.";
  try {
    const response = await ai.models.generateContent({
      model: 'gemini-3-flash-preview',
      contents: `Analyze this invoice summary data and give 3 bullet points on sales performance and outstanding payments. Keep it brief. Data: ${invoicesSummary}`,
    });
    const result = response.text;
    return typeof result === 'string' ? result : "No insights available.";
  } catch (error) {
    return "No insights available.";
  }
}