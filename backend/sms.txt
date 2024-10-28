import spacy
import re
import pandas as pd

# Load the spaCy model
nlp = spacy.load("en_core_web_sm")

def extract_transaction_info(text):
    """Extract transaction details from a single SMS."""
    doc = nlp(text)
    
    account_pattern = r"A/C \*?(\d{4,})|A/C (\d{10})|A/c XX(\d{4})"
    amount_pattern = r"Rs\.?\s?\d+(?:,\d{3})*(?:\.\d{2})?|INR\s?\d+(?:,\d{3})*(?:\.\d{2})?"
    date_pattern = r"(?:on\s+)?(\d{1,2}-\d{1,2}-\d{4}|\d{2}/\d{2}/\d{4})"

    account_number = re.search(account_pattern, text)
    amount = re.search(amount_pattern, text)
    date = re.search(date_pattern, text)

    receiver = None
    potential_receivers = [ent.text for ent in doc.ents if ent.label_ == "PERSON"]
    if potential_receivers:
        receiver = potential_receivers[-1]

    return {
        "Receiver": receiver,
        "Account Number": account_number.group(0) if account_number else None,
        "Amount": amount.group(0) if amount else None,
        "Date": date.group(1) if date else None
    }

def preprocess_text(text):
    """Lowercase and clean text."""
    return re.sub(r'[^a-z\s]', '', text.lower()) if text else None

categories = {
    'food': ['starbucks', 'mcdonalds', 'dominos'],
    'clothing': ['nike', 'h&m', 'adidas'],
    'accessories': ['watch', 'jewelry'],
    'Bank Transfer': ['funds transfer']
}

def classify_receiver(receiver):
    """Classify the payment receiver into a category."""
    if receiver:
        for category, keywords in categories.items():
            if any(keyword.lower() in receiver.lower() for keyword in keywords):
                return category
    return 'other'

def parse_sms_list(sms_list):
    """Parse a list of SMS messages and return the results."""
    extracted_data = [extract_transaction_info(sms) for sms in sms_list]
    df = pd.DataFrame(extracted_data)
    df['Receiver'] = df['Receiver'].apply(preprocess_text)
    df['Category'] = df['Receiver'].apply(classify_receiver)
    return df.to_dict(orient='records')
