/* eslint-disable react/prop-types */
import {
  Drawer,
  DrawerClose,
  DrawerContent,
  DrawerFooter,
  DrawerHeader,
  DrawerTitle,
  DrawerTrigger,
} from "@/components/ui/drawer";
import { Button } from "./ui/button";
import { Input } from "./ui/input";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { useForm } from "react-hook-form";
import useFetch from "@/hooks/use-fetch";
import { addNewCompany } from "@/api/apiCompanies";
import { BarLoader } from "react-spinners";
import { useEffect, useState } from "react";

const schema = z.object({
  name: z.string().min(1, { message: "Company name is required" }),
  logo: z
    .any()
    .refine(
      (file) =>
        file[0] &&
        (file[0].type === "image/png" || 
         file[0].type === "image/jpeg" || 
         file[0].type === "image/webp" ||
         file[0].type === "image/svg+xml"),
      {
        message: "Only PNG, JPEG, WebP, and SVG images are allowed",
      }
    )
    .refine(
      (file) => file[0] && file[0].size <= 5 * 1024 * 1024, // 5MB limit
      {
        message: "File size must be less than 5MB",
      }
    ),
});

const AddCompanyDrawer = ({ fetchCompanies }) => {
  const [isOpen, setIsOpen] = useState(false);
  
  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
  } = useForm({
    resolver: zodResolver(schema),
  });

  const {
    loading: loadingAddCompany,
    error: errorAddCompany,
    data: dataAddCompany,
    fn: fnAddCompany,
  } = useFetch(addNewCompany);

  const onSubmit = async (data) => {
    try {
      await fnAddCompany({
        ...data,
        logo: data.logo[0],
      });
    } catch (error) {
      console.error("Error adding company:", error);
    }
  };

  useEffect(() => {
    if (dataAddCompany?.length > 0) {
      fetchCompanies();
      reset();
      setIsOpen(false);
    }
  }, [dataAddCompany, fetchCompanies, reset]);

  return (
    <Drawer open={isOpen} onOpenChange={setIsOpen}>
      <DrawerTrigger asChild>
        <Button type="button" size="sm" variant="secondary">
          Add Company
        </Button>
      </DrawerTrigger>
      <DrawerContent>
        <DrawerHeader>
          <DrawerTitle>Add a New Company</DrawerTitle>
        </DrawerHeader>
        <form className="flex gap-2 p-4 pb-0" onSubmit={handleSubmit(onSubmit)}>
          {/* Company Name */}
          <Input 
            placeholder="Company name" 
            {...register("name")}
            disabled={loadingAddCompany}
          />

          {/* Company Logo */}
          <Input
            type="file"
            accept="image/png,image/jpeg,image/webp,image/svg+xml"
            className="file:text-gray-500"
            {...register("logo")}
            disabled={loadingAddCompany}
          />

          {/* Add Button */}
          <Button
            type="submit"
            variant="destructive"
            className="w-40"
            disabled={loadingAddCompany}
          >
            {loadingAddCompany ? "Adding..." : "Add"}
          </Button>
        </form>
        <DrawerFooter>
          {errors.name && <p className="text-red-500">{errors.name.message}</p>}
          {errors.logo && <p className="text-red-500">{errors.logo.message}</p>}
          {errorAddCompany?.message && (
            <p className="text-red-500">{errorAddCompany?.message}</p>
          )}
          {loadingAddCompany && <BarLoader width={"100%"} color="#36d7b7" />}
          <DrawerClose asChild>
            <Button type="button" variant="secondary" disabled={loadingAddCompany}>
              Cancel
            </Button>
          </DrawerClose>
        </DrawerFooter>
      </DrawerContent>
    </Drawer>
  );
};

export default AddCompanyDrawer;