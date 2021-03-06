﻿using System;
using System.Collections.Generic;
using System.Data;
using System.Data.SqlClient;
using System.Threading.Tasks;
using System.Transactions;
using Tellma.Entities;
using Tellma.Entities.Descriptors;

namespace Tellma.Data
{
    public static class RepositoryUtilities
    {
        /// <summary>
        /// Constructs a SQL data table containing all the public properties of the 
        /// entities' type and populates the data table with the provided entities.
        /// This function automatically adds index columns for self referencing properties
        /// </summary>
        public static DataTable DataTable<T>(IEnumerable<T> entities, bool addIndex = false, IEnumerable<ExtraColumn<T>> extraColumns = null) where T : Entity
        {
            DataTable table = new DataTable();
            if (addIndex)
            {
                // The column order MUST match the column order in the user-defined table type
                table.Columns.Add(new DataColumn("Index", typeof(int)));
            }

            var props = AddColumnsFromProperties(table, extraColumns);

            int index = 0;
            foreach (var entity in entities)
            {
                if (entity != null)
                {
                    DataRow row = table.NewRow();

                    // We add an index property since SQL works with un-ordered sets
                    if (addIndex)
                    {
                        row["Index"] = index;
                    }

                    // Add the remaining properties
                    foreach (var prop in props)
                    {
                        if (prop.IsSelfReferencing)
                        {
                            object indexValue = prop.GetIndexProperty(entity);
                            row[prop.IndexPropertyName] = indexValue ?? DBNull.Value;
                        }

                        var propValue = prop.GetValue(entity);
                        row[prop.Name] = propValue ?? DBNull.Value;
                    }

                    // Custom columns
                    if (extraColumns != null)
                    {
                        foreach (var extra in extraColumns)
                        {
                            var propValue = extra.GetValue(entity);
                            row[extra.Name] = propValue ?? DBNull.Value;
                        }
                    }

                    table.Rows.Add(row);
                }

                index++;
            }



            return table;
        }

        public static DataTable DataTableWithHeaderIndex<THeader, TLines>(IEnumerable<THeader> entities, Func<THeader, List<TLines>> linesFunc, IEnumerable<ExtraColumn<TLines>> extraColumns = null) where THeader : Entity where TLines : Entity
        {
            DataTable table = new DataTable();

            // The column order MUST match the column order in the user-defined table type
            table.Columns.Add(new DataColumn("Index", typeof(int)));
            table.Columns.Add(new DataColumn("HeaderIndex", typeof(int)));

            var props = AddColumnsFromProperties(table, extraColumns);

            int headerIndex = 0;
            foreach (var entity in entities)
            {
                int index = 0;
                var lines = linesFunc(entity);
                if (lines != null)
                {
                    foreach (var line in linesFunc(entity))
                    {
                        DataRow row = table.NewRow();

                        // We add an index property since SQL works with un-ordered sets
                        row["Index"] = index++;
                        row["HeaderIndex"] = headerIndex;

                        // Add the remaining properties
                        foreach (var prop in props)
                        {
                            if (prop.IsSelfReferencing)
                            {
                                // This will probably never be used, we don't have self referencing properties on weak entities
                                object indexValue = prop.GetIndexProperty(entity);
                                row[prop.IndexPropertyName] = indexValue ?? DBNull.Value;
                            }

                            var propValue = prop.GetValue(line);
                            row[prop.Name] = propValue ?? DBNull.Value;
                        }

                        // Custom columns
                        if (extraColumns != null)
                        {
                            foreach (var extra in extraColumns)
                            {
                                var propValue = extra.GetValue(line);
                                row[extra.Name] = propValue ?? DBNull.Value;
                            }
                        }

                        table.Rows.Add(row);
                    }
                }

                headerIndex++;
            }

            return table;
        }

        public static (DataTable documents, DataTable lineDefinitionEntries, DataTable lines, DataTable entries, DataTable attachments) DataTableFromDocuments(IEnumerable<DocumentForSave> documents)
        {
            // Prepare the documents table skeleton
            DataTable docsTable = new DataTable();
            docsTable.Columns.Add(new DataColumn("Index", typeof(int)));
            var docsProps = AddColumnsFromProperties<DocumentForSave>(docsTable);
            docsTable.Columns.Add(new DataColumn("UpdateAttachments", typeof(bool)));

            // Prepare the line definition entries table skeleton
            DataTable lineDefinitionEntriesTable = new DataTable();
            lineDefinitionEntriesTable.Columns.Add(new DataColumn("Index", typeof(int)));
            lineDefinitionEntriesTable.Columns.Add(new DataColumn("DocumentIndex", typeof(int)));
            var lineDefinitionEntriesProps = AddColumnsFromProperties<DocumentLineDefinitionEntryForSave>(lineDefinitionEntriesTable);

            // Prepare the lines table skeleton
            DataTable linesTable = new DataTable();
            linesTable.Columns.Add(new DataColumn("Index", typeof(int)));
            linesTable.Columns.Add(new DataColumn("DocumentIndex", typeof(int)));
            var linesProps = AddColumnsFromProperties<LineForSave>(linesTable);

            // Prepare the entries table skeleton
            DataTable entriesTable = new DataTable();
            entriesTable.Columns.Add(new DataColumn("Index", typeof(int)));
            entriesTable.Columns.Add(new DataColumn("LineIndex", typeof(int)));
            entriesTable.Columns.Add(new DataColumn("DocumentIndex", typeof(int)));
            var entriesProps = AddColumnsFromProperties<EntryForSave>(entriesTable);

            // Prepare the attachments table skeleton
            DataTable attachmentsTable = new DataTable();
            attachmentsTable.Columns.Add(new DataColumn("DocumentIndex", typeof(int)));
            var attachmentsProps = AddColumnsFromProperties<AttachmentForSave>(attachmentsTable);
            attachmentsTable.Columns.Add(new DataColumn("FileId", typeof(string)));
            attachmentsTable.Columns.Add(new DataColumn("FileSize", typeof(long)));

            // Add the docs
            int docsIndex = 0;
            foreach (var doc in documents)
            {
                DataRow docsRow = docsTable.NewRow();

                docsRow["Index"] = docsIndex;

                foreach (var docsProp in docsProps)
                {
                    var docsPropValue = docsProp.GetValue(doc);
                    docsRow[docsProp.Name] = docsPropValue ?? DBNull.Value;
                }

                docsRow["UpdateAttachments"] = doc.Attachments != null; // Instructs the SP whether to update the attachments or not

                // Add line definition entries if any
                if (doc.LineDefinitionEntries != null)
                {
                    doc.LineDefinitionEntries.ForEach(lineDefinitionEntry =>
                    {
                        DataRow lineDefinitionEntriesRow = lineDefinitionEntriesTable.NewRow();

                        lineDefinitionEntriesRow["Index"] = lineDefinitionEntry.EntityMetadata.OriginalIndex; // This collection gets culled, so we rely on the preserved index here
                        lineDefinitionEntriesRow["DocumentIndex"] = docsIndex;

                        foreach (var lineDefinitionEntryProp in lineDefinitionEntriesProps)
                        {
                            var lineDefinitionEntriesPropValue = lineDefinitionEntryProp.GetValue(lineDefinitionEntry);
                            lineDefinitionEntriesRow[lineDefinitionEntryProp.Name] = lineDefinitionEntriesPropValue ?? DBNull.Value;
                        }

                        lineDefinitionEntriesTable.Rows.Add(lineDefinitionEntriesRow);
                    });
                }

                // Add the lines if any
                if (doc.Lines != null)
                {
                    int linesIndex = 0;
                    doc.Lines.ForEach(line =>
                    {
                        DataRow linesRow = linesTable.NewRow();

                        linesRow["Index"] = linesIndex;
                        linesRow["DocumentIndex"] = docsIndex;

                        foreach (var linesProp in linesProps)
                        {
                            var linesPropValue = linesProp.GetValue(line);
                            linesRow[linesProp.Name] = linesPropValue ?? DBNull.Value;
                        }

                        if (line.Entries != null)
                        {
                            int entriesIndex = 0;
                            line.Entries.ForEach(entry =>
                            {
                                DataRow entriesRow = entriesTable.NewRow();

                                entriesRow["Index"] = entriesIndex;
                                entriesRow["LineIndex"] = linesIndex;
                                entriesRow["DocumentIndex"] = docsIndex;

                                foreach (var entriesProp in entriesProps)
                                {
                                    var entriesPropValue = entriesProp.GetValue(entry);
                                    entriesRow[entriesProp.Name] = entriesPropValue ?? DBNull.Value;
                                }

                                entriesTable.Rows.Add(entriesRow);
                                entriesIndex++;
                            });
                        }

                        linesTable.Rows.Add(linesRow);
                        linesIndex++;
                    });
                }

                // Add the attachments if any
                if (doc.Attachments != null)
                {
                    doc.Attachments.ForEach(attachment =>
                    {
                        DataRow attachmentsRow = attachmentsTable.NewRow();

                        attachmentsRow["DocumentIndex"] = docsIndex;

                        foreach (var attachmentsProp in attachmentsProps)
                        {
                            var attachmentsPropValue = attachmentsProp.GetValue(attachment);
                            attachmentsRow[attachmentsProp.Name] = attachmentsPropValue ?? DBNull.Value;
                        }

                        attachmentsRow["FileId"] = attachment.EntityMetadata?.FileId;
                        attachmentsRow["FileSize"] = attachment.EntityMetadata?.FileSize;

                        attachmentsTable.Rows.Add(attachmentsRow);
                    });
                }

                docsTable.Rows.Add(docsRow);
                docsIndex++;
            }

            return (docsTable, lineDefinitionEntriesTable, linesTable, entriesTable, attachmentsTable);
        }

        public static (
            DataTable lineDefinitions,
            DataTable lineDefinitionEntries,
            DataTable lineDefinitionEntryCustodyDefinitions,
            DataTable lineDefinitionEntryResourceDefinitions,
            DataTable lineDefinitionColumns,
            DataTable lineDefinitionGenerateParameters,
            DataTable lineDefinitionStateReasons,
            DataTable workflows,
            DataTable workflowSignatures)
            DataTableFromLineDefinitions(IEnumerable<LineDefinitionForSave> lineDefinitions)
        {
            DataTable lineDefinitionsTable = new DataTable();
            lineDefinitionsTable.Columns.Add(new DataColumn("Index", typeof(int)));
            var lineDefinitionProps = AddColumnsFromProperties<LineDefinitionForSave>(lineDefinitionsTable);

            DataTable lineDefinitionEntriesTable = new DataTable();
            lineDefinitionEntriesTable.Columns.Add(new DataColumn("Index", typeof(int)));
            lineDefinitionEntriesTable.Columns.Add(new DataColumn("HeaderIndex", typeof(int)));
            var lineDefinitionEntryProps = AddColumnsFromProperties<LineDefinitionEntryForSave>(lineDefinitionEntriesTable);

            DataTable lineDefinitionEntryCustodyDefinitionsTable = new DataTable();
            lineDefinitionEntryCustodyDefinitionsTable.Columns.Add(new DataColumn("Index", typeof(int)));
            lineDefinitionEntryCustodyDefinitionsTable.Columns.Add(new DataColumn("LineDefinitionEntryIndex", typeof(int)));
            lineDefinitionEntryCustodyDefinitionsTable.Columns.Add(new DataColumn("LineDefinitionIndex", typeof(int)));
            var lineDefinitionEntryCustodyDefinitionProps = AddColumnsFromProperties<LineDefinitionEntryCustodyDefinitionForSave>(lineDefinitionEntryCustodyDefinitionsTable);

            DataTable lineDefinitionEntryResourceDefinitionsTable = new DataTable();
            lineDefinitionEntryResourceDefinitionsTable.Columns.Add(new DataColumn("Index", typeof(int)));
            lineDefinitionEntryResourceDefinitionsTable.Columns.Add(new DataColumn("LineDefinitionEntryIndex", typeof(int)));
            lineDefinitionEntryResourceDefinitionsTable.Columns.Add(new DataColumn("LineDefinitionIndex", typeof(int)));
            var lineDefinitionEntryResourceDefinitionProps = AddColumnsFromProperties<LineDefinitionEntryResourceDefinitionForSave>(lineDefinitionEntryResourceDefinitionsTable);

            DataTable lineDefinitionColumnsTable = new DataTable();
            lineDefinitionColumnsTable.Columns.Add(new DataColumn("Index", typeof(int)));
            lineDefinitionColumnsTable.Columns.Add(new DataColumn("HeaderIndex", typeof(int)));
            var lineDefinitionColumnProps = AddColumnsFromProperties<LineDefinitionColumnForSave>(lineDefinitionColumnsTable);

            DataTable lineDefinitionGenerateParametersTable = new DataTable();
            lineDefinitionGenerateParametersTable.Columns.Add(new DataColumn("Index", typeof(int)));
            lineDefinitionGenerateParametersTable.Columns.Add(new DataColumn("HeaderIndex", typeof(int)));
            var lineDefinitionGenerateParameterProps = AddColumnsFromProperties<LineDefinitionGenerateParameterForSave>(lineDefinitionGenerateParametersTable);

            DataTable lineDefinitionStateReasonsTable = new DataTable();
            lineDefinitionStateReasonsTable.Columns.Add(new DataColumn("Index", typeof(int)));
            lineDefinitionStateReasonsTable.Columns.Add(new DataColumn("HeaderIndex", typeof(int)));
            var lineDefinitionStateReasonProps = AddColumnsFromProperties<LineDefinitionStateReasonForSave>(lineDefinitionStateReasonsTable);

            DataTable workflowsTable = new DataTable();
            workflowsTable.Columns.Add(new DataColumn("Index", typeof(int)));
            workflowsTable.Columns.Add(new DataColumn("LineDefinitionIndex", typeof(int)));
            var workflowProps = AddColumnsFromProperties<WorkflowForSave>(workflowsTable);

            DataTable workflowSignaturesTable = new DataTable();
            workflowSignaturesTable.Columns.Add(new DataColumn("Index", typeof(int)));
            workflowSignaturesTable.Columns.Add(new DataColumn("WorkflowIndex", typeof(int)));
            workflowSignaturesTable.Columns.Add(new DataColumn("LineDefinitionIndex", typeof(int)));
            var workflowSignatureProps = AddColumnsFromProperties<WorkflowSignatureForSave>(workflowSignaturesTable);

            // LineDefinitions
            int lineDefinitionIndex = 0;
            foreach (var lineDefinition in lineDefinitions)
            {
                DataRow lineDefinitionsRow = lineDefinitionsTable.NewRow();

                lineDefinitionsRow["Index"] = lineDefinitionIndex;
                foreach (var prop in lineDefinitionProps)
                {
                    var value = prop.GetValue(lineDefinition);
                    lineDefinitionsRow[prop.Name] = value ?? DBNull.Value;
                }

                // Entries
                if (lineDefinition.Entries != null)
                {
                    int lineDefinitionEntryIndex = 0;
                    lineDefinition.Entries.ForEach(lineDefinitionEntry =>
                    {
                        DataRow lineDefinitionEntriesRow = lineDefinitionEntriesTable.NewRow();

                        lineDefinitionEntriesRow["Index"] = lineDefinitionEntryIndex;
                        lineDefinitionEntriesRow["HeaderIndex"] = lineDefinitionIndex;
                        foreach (var prop in lineDefinitionEntryProps)
                        {
                            var value = prop.GetValue(lineDefinitionEntry);
                            lineDefinitionEntriesRow[prop.Name] = value ?? DBNull.Value;
                        }

                        // Entries.CustodyDefinitions
                        if (lineDefinitionEntry.CustodyDefinitions != null)
                        {
                            int lineDefinitionEntryCustodyDefinitionIndex = 0;
                            lineDefinitionEntry.CustodyDefinitions.ForEach(lineDefinitionEntryCustodyDefinition =>
                            {
                                DataRow lineDefinitionEntryCustodyDefinitionsRow = lineDefinitionEntryCustodyDefinitionsTable.NewRow();

                                lineDefinitionEntryCustodyDefinitionsRow["Index"] = lineDefinitionEntryCustodyDefinitionIndex;
                                lineDefinitionEntryCustodyDefinitionsRow["LineDefinitionEntryIndex"] = lineDefinitionEntryIndex;
                                lineDefinitionEntryCustodyDefinitionsRow["LineDefinitionIndex"] = lineDefinitionIndex;

                                foreach (var prop in lineDefinitionEntryCustodyDefinitionProps)
                                {
                                    var value = prop.GetValue(lineDefinitionEntryCustodyDefinition);
                                    lineDefinitionEntryCustodyDefinitionsRow[prop.Name] = value ?? DBNull.Value;
                                }

                                lineDefinitionEntryCustodyDefinitionsTable.Rows.Add(lineDefinitionEntryCustodyDefinitionsRow);
                                lineDefinitionEntryCustodyDefinitionIndex++;
                            });
                        }

                        // Entries.ResourceDefinitions
                        if (lineDefinitionEntry.ResourceDefinitions != null)
                        {
                            int lineDefinitionEntryResourceDefinitionIndex = 0;
                            lineDefinitionEntry.ResourceDefinitions.ForEach(lineDefinitionEntryResourceDefinition =>
                            {
                                DataRow lineDefinitionEntryResourceDefinitionsRow = lineDefinitionEntryResourceDefinitionsTable.NewRow();

                                lineDefinitionEntryResourceDefinitionsRow["Index"] = lineDefinitionEntryResourceDefinitionIndex;
                                lineDefinitionEntryResourceDefinitionsRow["LineDefinitionEntryIndex"] = lineDefinitionEntryIndex;
                                lineDefinitionEntryResourceDefinitionsRow["LineDefinitionIndex"] = lineDefinitionIndex;

                                foreach (var prop in lineDefinitionEntryResourceDefinitionProps)
                                {
                                    var value = prop.GetValue(lineDefinitionEntryResourceDefinition);
                                    lineDefinitionEntryResourceDefinitionsRow[prop.Name] = value ?? DBNull.Value;
                                }

                                lineDefinitionEntryResourceDefinitionsTable.Rows.Add(lineDefinitionEntryResourceDefinitionsRow);
                                lineDefinitionEntryResourceDefinitionIndex++;
                            });
                        }

                        lineDefinitionEntriesTable.Rows.Add(lineDefinitionEntriesRow);
                        lineDefinitionEntryIndex++;
                    });
                }

                // Columns
                if (lineDefinition.Columns != null)
                {
                    int lineDefinitionColumnIndex = 0;
                    lineDefinition.Columns.ForEach(lineDefinitionColumn =>
                    {
                        DataRow lineDefinitionColumnsRow = lineDefinitionColumnsTable.NewRow();

                        lineDefinitionColumnsRow["Index"] = lineDefinitionColumnIndex;
                        lineDefinitionColumnsRow["HeaderIndex"] = lineDefinitionIndex;
                        foreach (var prop in lineDefinitionColumnProps)
                        {
                            var value = prop.GetValue(lineDefinitionColumn);
                            lineDefinitionColumnsRow[prop.Name] = value ?? DBNull.Value;
                        }

                        lineDefinitionColumnsTable.Rows.Add(lineDefinitionColumnsRow);
                        lineDefinitionColumnIndex++;
                    });
                }

                // GenerateParameters
                if (lineDefinition.GenerateParameters != null)
                {
                    int lineDefinitionGenerateParameterIndex = 0;
                    lineDefinition.GenerateParameters.ForEach(lineDefinitionGenerateParameter =>
                    {
                        DataRow lineDefinitionGenerateParametersRow = lineDefinitionGenerateParametersTable.NewRow();

                        lineDefinitionGenerateParametersRow["Index"] = lineDefinitionGenerateParameterIndex;
                        lineDefinitionGenerateParametersRow["HeaderIndex"] = lineDefinitionIndex;
                        foreach (var prop in lineDefinitionGenerateParameterProps)
                        {
                            var value = prop.GetValue(lineDefinitionGenerateParameter);
                            lineDefinitionGenerateParametersRow[prop.Name] = value ?? DBNull.Value;
                        }

                        lineDefinitionGenerateParametersTable.Rows.Add(lineDefinitionGenerateParametersRow);
                        lineDefinitionGenerateParameterIndex++;
                    });
                }

                // StateReasons
                if (lineDefinition.StateReasons != null)
                {
                    int lineDefinitionStateReasonIndex = 0;
                    lineDefinition.StateReasons.ForEach(lineDefinitionStateReason =>
                    {
                        DataRow lineDefinitionStateReasonsRow = lineDefinitionStateReasonsTable.NewRow();

                        lineDefinitionStateReasonsRow["Index"] = lineDefinitionStateReasonIndex;
                        lineDefinitionStateReasonsRow["HeaderIndex"] = lineDefinitionIndex;
                        foreach (var prop in lineDefinitionStateReasonProps)
                        {
                            var value = prop.GetValue(lineDefinitionStateReason);
                            lineDefinitionStateReasonsRow[prop.Name] = value ?? DBNull.Value;
                        }

                        lineDefinitionStateReasonsTable.Rows.Add(lineDefinitionStateReasonsRow);
                        lineDefinitionStateReasonIndex++;
                    });
                }

                // Workflows
                if (lineDefinition.Workflows != null)
                {
                    int workflowIndex = 0;
                    lineDefinition.Workflows.ForEach(workflow =>
                    {
                        DataRow workflowsRow = workflowsTable.NewRow();

                        workflowsRow["Index"] = workflowIndex;
                        workflowsRow["LineDefinitionIndex"] = lineDefinitionIndex;
                        foreach (var prop in workflowProps)
                        {
                            var value = prop.GetValue(workflow);
                            workflowsRow[prop.Name] = value ?? DBNull.Value;
                        }

                        // Workflows.Signatures
                        if (workflow.Signatures != null)
                        {
                            int workflowSignatureIndex = 0;
                            workflow.Signatures.ForEach(workflowSignature =>
                            {
                                DataRow workflowSignaturesRow = workflowSignaturesTable.NewRow();

                                workflowSignaturesRow["Index"] = workflowSignatureIndex;
                                workflowSignaturesRow["WorkflowIndex"] = workflowIndex;
                                workflowSignaturesRow["LineDefinitionIndex"] = lineDefinitionIndex;
                                foreach (var prop in workflowSignatureProps)
                                {
                                    var value = prop.GetValue(workflowSignature);
                                    workflowSignaturesRow[prop.Name] = value ?? DBNull.Value;
                                }


                                workflowSignaturesTable.Rows.Add(workflowSignaturesRow);
                                workflowSignatureIndex++;
                            });
                        }

                        workflowsTable.Rows.Add(workflowsRow);
                        workflowIndex++;
                    });
                }

                lineDefinitionsTable.Rows.Add(lineDefinitionsRow);
                lineDefinitionIndex++;
            }

            return (
                lineDefinitionsTable,
                lineDefinitionEntriesTable,
                lineDefinitionEntryCustodyDefinitionsTable,
                lineDefinitionEntryResourceDefinitionsTable,
                lineDefinitionColumnsTable,
                lineDefinitionGenerateParametersTable,
                lineDefinitionStateReasonsTable,
                workflowsTable,
                workflowSignaturesTable
                );
        }

        public static (DataTable rows, DataTable columns) DataTableFromReportDefinitionDimensionAttributes(IEnumerable<ReportDefinitionForSave> reports)
        {
            DataTable rowsAttributesTable = new DataTable();
            rowsAttributesTable.Columns.Add(new DataColumn("Index", typeof(int)));
            rowsAttributesTable.Columns.Add(new DataColumn("HeaderIndex", typeof(int)));
            rowsAttributesTable.Columns.Add(new DataColumn("ReportDefinitionIndex", typeof(int)));

            AddColumnsFromProperties<ReportDefinitionDimensionAttributeForSave>(rowsAttributesTable);

            DataTable colsAttributesTable = new DataTable();
            colsAttributesTable.Columns.Add(new DataColumn("Index", typeof(int)));
            colsAttributesTable.Columns.Add(new DataColumn("HeaderIndex", typeof(int)));
            colsAttributesTable.Columns.Add(new DataColumn("ReportDefinitionIndex", typeof(int)));

            var attributeProps = AddColumnsFromProperties<ReportDefinitionDimensionAttributeForSave>(colsAttributesTable);

            int reportIndex = 0;
            foreach (var report in reports)
            {
                int rowIndex = 0;
                foreach (var row in report.Rows)
                {
                    int attIndex = 0;
                    foreach (var att in row.Attributes)
                    {
                        DataRow rowAttributeRow = rowsAttributesTable.NewRow();

                        rowAttributeRow["Index"] = attIndex;
                        rowAttributeRow["HeaderIndex"] = rowIndex;
                        rowAttributeRow["ReportDefinitionIndex"] = reportIndex;

                        foreach (var attributeProp in attributeProps)
                        {
                            var propValue = attributeProp.GetValue(att);
                            rowAttributeRow[attributeProp.Name] = propValue ?? DBNull.Value;
                        }

                        rowsAttributesTable.Rows.Add(rowAttributeRow);
                        attIndex++;
                    }

                    rowIndex++;
                }

                int colIndex = 0;
                foreach (var col in report.Columns)
                {
                    int attIndex = 0;
                    foreach (var att in col.Attributes)
                    {
                        DataRow colAttributeRow = colsAttributesTable.NewRow();

                        colAttributeRow["Index"] = attIndex;
                        colAttributeRow["HeaderIndex"] = colIndex;
                        colAttributeRow["ReportDefinitionIndex"] = reportIndex;

                        foreach (var attributeProp in attributeProps)
                        {
                            var propValue = attributeProp.GetValue(att);
                            colAttributeRow[attributeProp.Name] = propValue ?? DBNull.Value;
                        }

                        colsAttributesTable.Rows.Add(colAttributeRow);
                        attIndex++;
                    }

                    colIndex++;
                }

                reportIndex++;
            }

            return (rowsAttributesTable, colsAttributesTable);
        }

        private static IEnumerable<PropertyDescriptor> AddColumnsFromProperties<T>(DataTable table, IEnumerable<ExtraColumn<T>> extras = null) where T : Entity
        {
            var props = TypeDescriptor.Get<T>().SimpleProperties;
            foreach (var prop in props)
            {
                // If it's a self referencing FK column, add the index first (by convention the index column immediate precedes the self ref FK column
                if (prop.IsSelfReferencing)
                {
                    var indexColumn = new DataColumn(prop.IndexPropertyName, typeof(int));
                    table.Columns.Add(indexColumn);
                }

                // Add the column itself
                var propType = Nullable.GetUnderlyingType(prop.Type) ?? prop.Type;
                var column = new DataColumn(prop.Name, propType);
                if (propType == typeof(string))
                {
                    // For string columns, it is more performant to explicitly specify the maximum column size
                    // According to this article: http://www.dbdelta.com/sql-server-tvp-performance-gotchas/
                    int maxLength = prop.MaxLength;
                    if (maxLength > 0)
                    {
                        column.MaxLength = maxLength;
                    }
                }

                table.Columns.Add(column);
            }

            if (extras != null)
            {
                foreach (var extra in extras)
                {
                    var column = new DataColumn(extra.Name, extra.Type);
                    table.Columns.Add(column);
                }
            }

            return props;
        }

        public static ExtraColumn<T> Column<T>(string name, Type type, Func<T, object> getValue)
        {
            return new ExtraColumn<T>
            {
                Name = name,
                Type = type,
                GetValue = getValue
            };
        }

        /// <summary>
        /// Determines whether the given exception is a foreign key violation on delete
        /// </summary>
        public static bool IsForeignKeyViolation(SqlException ex)
        {
            return ex.Number == 547;
        }

        /// <summary>
        /// Enlists the transaction in the ambient transaction, or in the transactionOverride if active
        /// </summary>
        public static void EnlistInTransaction(this SqlConnection conn, Transaction transactionOverride = null)
        {
            if (transactionOverride?.TransactionInformation.Status == TransactionStatus.Active)
            {
                conn.EnlistTransaction(transactionOverride);
            }
            else
            {
                conn.EnlistTransaction(Transaction.Current);
            }
        }

        /// <summary>
        /// Equivalent to <see cref="SqlDataReader.GetInt32(int)"/> but also handles the null case
        /// </summary
        public static int? Int32(this SqlDataReader reader, int index)
        {
            return reader.IsDBNull(index) ? (int?)null : reader.GetInt32(index);
        }

        /// <summary>
        /// Equivalent to <see cref="SqlDataReader.GetBoolean(int)"/> but also handles the null case
        /// </summary
        public static bool? Boolean(this SqlDataReader reader, int index)
        {
            return reader.IsDBNull(index) ? (bool?)null : reader.GetBoolean(index);
        }

        /// <summary>
        /// Equivalent to <see cref="SqlDataReader.GetInt16(int)"/> but also handles the null case
        /// </summary
        public static short? Int16(this SqlDataReader reader, int index)
        {
            return reader.IsDBNull(index) ? (short?)null : reader.GetInt16(index);
        }

        /// <summary>
        /// Equivalent to <see cref="SqlDataReader.GetDecimal(int)"/> but also handles the null case
        /// </summary
        public static decimal? Decimal(this SqlDataReader reader, int index)
        {
            return reader.IsDBNull(index) ? (decimal?)null : reader.GetDecimal(index);
        }

        /// <summary>
        /// Equivalent to <see cref="SqlDataReader.GetString(int)"/> but also handles the null case
        /// </summary
        public static string String(this SqlDataReader reader, int index)
        {
            return reader.IsDBNull(index) ? null : reader.GetString(index);
        }

        /// <summary>
        /// Equivalent to <see cref="SqlDataReader.GetDateTime(int)"/> but also handles the null case
        /// </summary
        public static DateTime? DateTime(this SqlDataReader reader, int index)
        {
            return reader.IsDBNull(index) ? (DateTime?)null : reader.GetDateTime(index);
        }

        /// <summary>
        /// Equivalent to <see cref="SqlDataReader.GetGuid(int)"/> but also handles the null case
        /// </summary
        public static Guid? Guid(this SqlDataReader reader, int index)
        {
            return reader.IsDBNull(index) ? (Guid?)null : reader.GetGuid(index);
        }

        public static object Value(this SqlDataReader reader, int index, string colNameToCheck = null)
        {
            if (colNameToCheck != null && colNameToCheck != reader.GetName(index))
            {
                throw new InvalidOperationException($"Attempt to load SQL column {colNameToCheck} into C# property {colNameToCheck}");
            }

            return reader.IsDBNull(index) ? null : reader.GetValue(index);
        }

        /// <summary>
        /// Extension method that adds <see cref="DBNull.Value"/> when the supplied value
        /// is null, instead of the default behavior of not adding anything at all
        /// </summary>
        public static SqlParameter Add(this SqlParameterCollection target, string parameterName, object value)
        {
            value ??= DBNull.Value;
            return target.AddWithValue(parameterName, value);
        }

        /// <summary>
        /// Loads the results of a validation stored procedure into a list of <see cref="ValidationError"/>
        /// </summary>
        public static async Task<List<ValidationError>> LoadErrors(SqlCommand cmd)
        {
            var result = new List<ValidationError>();

            using (var reader = await cmd.ExecuteReaderAsync())
            {
                while (await reader.ReadAsync())
                {
                    int i = 0;
                    result.Add(new ValidationError
                    {
                        Key = reader.String(i++),
                        ErrorName = reader.String(i++),
                        Argument1 = reader.String(i++),
                        Argument2 = reader.String(i++),
                        Argument3 = reader.String(i++),
                        Argument4 = reader.String(i++),
                        Argument5 = reader.String(i++)
                    });
                }
            }

            return result;
        }

        public static async Task<List<InboxNotificationInfo>> LoadAssignmentNotificationInfos(SqlDataReader reader, List<InboxNotificationInfo> result = null)
        {
            result ??= new List<InboxNotificationInfo>();

            while (await reader.ReadAsync())
            {
                int i = 0;
                result.Add(new InboxNotificationInfo
                {
                    ExternalId = reader.GetString(i++),
                    Count = reader.GetInt32(i++),
                    UnknownCount = reader.GetInt32(i++)
                });
            }

            return result;
        }
    }

    public class ExtraColumn<T>
    {
        /// <summary>
        /// Column name.
        /// </summary>
        public string Name { get; set; }

        /// <summary>
        /// Column type (don't use nullable).
        /// </summary>
        public Type Type { get; set; }

        /// <summary>
        /// Function that gets the value
        /// </summary>
        public Func<T, object> GetValue { get; set; }
    }
}
