-- Create enum for item status
CREATE TYPE item_status AS ENUM ('active', 'claimed', 'resolved');

-- Create enum for item categories
CREATE TYPE item_category AS ENUM ('electronics', 'documents', 'clothing', 'accessories', 'pets', 'keys', 'bags', 'other');

-- Create table for lost items
CREATE TABLE public.lost_items (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category item_category NOT NULL,
  location TEXT NOT NULL,
  date_lost DATE NOT NULL,
  status item_status NOT NULL DEFAULT 'active',
  photo_url TEXT,
  contact_name TEXT NOT NULL,
  contact_email TEXT NOT NULL,
  contact_phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Create table for found items
CREATE TABLE public.found_items (
  id UUID NOT NULL DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID NOT NULL,
  title TEXT NOT NULL,
  description TEXT NOT NULL,
  category item_category NOT NULL,
  location TEXT NOT NULL,
  date_found DATE NOT NULL,
  status item_status NOT NULL DEFAULT 'active',
  photo_url TEXT,
  contact_name TEXT NOT NULL,
  contact_email TEXT NOT NULL,
  contact_phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now(),
  updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT now()
);

-- Enable Row Level Security
ALTER TABLE public.lost_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE public.found_items ENABLE ROW LEVEL SECURITY;

-- RLS Policies for lost_items
CREATE POLICY "Anyone can view active lost items"
  ON public.lost_items
  FOR SELECT
  USING (status = 'active' OR auth.uid() = user_id);

CREATE POLICY "Authenticated users can insert lost items"
  ON public.lost_items
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own lost items"
  ON public.lost_items
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own lost items"
  ON public.lost_items
  FOR DELETE
  USING (auth.uid() = user_id);

-- RLS Policies for found_items
CREATE POLICY "Anyone can view active found items"
  ON public.found_items
  FOR SELECT
  USING (status = 'active' OR auth.uid() = user_id);

CREATE POLICY "Authenticated users can insert found items"
  ON public.found_items
  FOR INSERT
  WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Users can update their own found items"
  ON public.found_items
  FOR UPDATE
  USING (auth.uid() = user_id);

CREATE POLICY "Users can delete their own found items"
  ON public.found_items
  FOR DELETE
  USING (auth.uid() = user_id);

-- Create function to update timestamps
CREATE OR REPLACE FUNCTION public.update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = now();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SET search_path = public;

-- Create triggers for automatic timestamp updates
CREATE TRIGGER update_lost_items_updated_at
  BEFORE UPDATE ON public.lost_items
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();

CREATE TRIGGER update_found_items_updated_at
  BEFORE UPDATE ON public.found_items
  FOR EACH ROW
  EXECUTE FUNCTION public.update_updated_at_column();
